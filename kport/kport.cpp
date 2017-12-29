// kport.cpp : Defines the entry point for the DLL application.
//
#include "StdAfx.h"
#include "Kport.h"
#include <winioctl.h>
#include "kioport.h"

HANDLE     hKport;        /* Handle for KioPort Driver */
//Prototip of functions////////////////////////////////////
WORD APIENTRY OpenPort(void);   //1 call
BYTE StartPortDriver(void);	  //2 call
void InstallPortDriver(void);   //3 call
void APIENTRY ClosePort(void);  //4 call
//Helper////////////////////////////////////////////////////
BOOL APIENTRY Is_Win2000_Professional (void);
/////////////////////////////////////////////////////////////
BOOL APIENTRY DllMain( HANDLE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved )
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
		{
			//MessageBox(NULL,"Opening","Kport-DLL",MB_ICONINFORMATION);
			//InstallPortDriver();
			OpenPort();
			break;
		}

	case DLL_THREAD_ATTACH: break;		
	case DLL_THREAD_DETACH:	break;

	case DLL_PROCESS_DETACH:
		{
			//MessageBox(NULL,"Closing","Kport-DLL",MB_ICONINFORMATION);
			ClosePort();
			break;
		}
	}
    return TRUE;
}

// Write a value to specific ports.
KPORT_API void APIENTRY Outportb(WORD PortNum, BYTE byte)
{
    UINT error;
    DWORD BytesReturned;        
    BYTE Buffer[3];
    WORD * pBuffer;
    pBuffer = (WORD *)&Buffer[0];
    *pBuffer = PortNum;
    Buffer[2] = byte;
	LPSTR szt = NULL;

    error = DeviceIoControl(hKport,
                            IOCTL_WRITE_PORT_UCHAR,
                            &Buffer,
                            3,
                            NULL,
                            0,
                            &BytesReturned,
                            NULL);

    if (!error) 
	{	
		wsprintf(szt,"Error occured during outportb while talking to KioPort driver %d\n",GetLastError());
		MessageBox(NULL,szt,"Kport-DLL",MB_ICONINFORMATION);
	}
}

// Returns a value from specific ports.
KPORT_API BYTE APIENTRY Inportb(WORD PortNum)
{   
	UINT error;
    DWORD BytesReturned;
    BYTE Buffer[3];
    WORD *pBuffer;
    pBuffer = (WORD*)&Buffer;
    *pBuffer = PortNum;
	LPSTR szt = NULL;

    error = DeviceIoControl(hKport,
                            IOCTL_READ_PORT_UCHAR,
                            &Buffer,
                            2,
                            &Buffer,
                            1,
                            &BytesReturned,
                            NULL);

    if (!error)
	{
		wsprintf(szt,"Error occured during inportb while talking to KioPort driver %d\n",GetLastError());
		MessageBox(NULL,szt,"Kport-DLL",MB_ICONINFORMATION);
	}
		
    return(Buffer[0]);
}


WORD APIENTRY OpenPort(void)
{
	
  /* Open KioPort Driver. If we cannot open it, try installing and starting it */
    hKport = CreateFile("\\\\.\\KioPort", 
                                 GENERIC_READ, 
                                 0, 
                                 NULL,
                                 OPEN_EXISTING, 
                                 FILE_ATTRIBUTE_NORMAL, 
                                 NULL);

    if(hKport == INVALID_HANDLE_VALUE) {
            /* Start or Install KioPort Driver */
            StartPortDriver();
            /* Then try to open once more, before failing */
            hKport = CreateFile("\\\\.\\KioPort", 
                                         GENERIC_READ, 
                                         0, 
                                         NULL,
                                         OPEN_EXISTING, 
                                         FILE_ATTRIBUTE_NORMAL, 
                                         NULL);
				  
            if(hKport == INVALID_HANDLE_VALUE) {
					MessageBox(NULL,"Couldn't access KioPort Driver,\n Please ensure driver is loaded.\n","Kport-DLL",MB_ICONINFORMATION);
                    return -1;	
            }
    }
	return 0;
}

BYTE StartPortDriver(void)
{
	SC_HANDLE  SchSCManager;
    SC_HANDLE  schService;
    BOOL       ret;
    DWORD      err;

    /* Open Handle to Service Control Manager */
    SchSCManager = OpenSCManager (NULL,                        /* machine (NULL == local) */
                                  NULL,                        /* database (NULL == default) */
                                  SC_MANAGER_ALL_ACCESS);      /* access required */
                         
    if (SchSCManager == NULL)
      if (GetLastError() == ERROR_ACCESS_DENIED) {
         /* We do not have enough rights to open the SCM, therefore we must */
         /* be a poor user with only user rights. */
         MessageBox(NULL,"You do not have rights to access the Service Control Manager and\n the KioPort driver is not installed or started. Please ask\n your administrator to install the driver on your behalf.\n",
							"Kport-DLL",MB_ICONINFORMATION );
          return(0);
         }

    do {
         /* Open a Handle to the KioPort Service Database */
         schService = OpenService(SchSCManager,         /* handle to service control manager database */
                                  "KioPort",           /* pointer to name of service to start */
                                  SERVICE_ALL_ACCESS);  /* type of access to service */

         if (schService == NULL)
            switch (GetLastError())
		   {
                case ERROR_ACCESS_DENIED:
					MessageBox(NULL,"You do not have rights to the KioPort service database","Kport-DLL",MB_ICONINFORMATION);
                          return(0);
                case ERROR_INVALID_NAME:
					MessageBox(NULL,"The specified service name is invalid.","Kport-DLL",MB_ICONINFORMATION);
                          return(0);
                case ERROR_SERVICE_DOES_NOT_EXIST:
					{
					  MessageBox(NULL,"The KioPort driver does not exist. Installing driver.\nThis can take up to 30 seconds on some machines...",
						"Kport-DLL",MB_ICONINFORMATION);
					      InstallPortDriver();
					  MessageBox(NULL,"...Done","Kport-DLL",MB_ICONINFORMATION);
					}
                        break;
            }
        } while (schService == NULL);

    /* Start the KioPort Driver. Errors will occur here if KioPort.SYS file doesn't exist */
    
    ret = StartService (schService,    /* service identifier */
                        0,             /* number of arguments */
                        NULL);         /* pointer to arguments */
                    
    if (ret) 
		MessageBox(NULL,"The KioPort driver has been successfully started.\n","Kport-DLL",MB_ICONINFORMATION);
	else {
        err = GetLastError();
        if (err == ERROR_SERVICE_ALREADY_RUNNING)
			MessageBox(NULL,"The KioPort driver is already running.\n","Kport-DLL",MB_ICONINFORMATION);
        else {
			
			MessageBox(NULL,"Unknown error while starting KioPort driver service.\nDoes kioport.sys exist in your \\System32\\Drivers Directory?",
				"Kport-DLL",MB_ICONQUESTION);
			
            return(0);
        }
    }

    /* Close handle to Service Control Manager */
    CloseServiceHandle (schService);
    return(TRUE);
}

void InstallPortDriver(void)
{
	SC_HANDLE  SchSCManager;
    SC_HANDLE  schService;
    DWORD      err;
    char       DriverFileName[80];

    /* Get Current Directory. Assumes KioPort.SYS driver is in this directory.    */
    /* Doesn't detect if file exists, nor if file is on removable media - if this  */
    /* is the case then when windows next boots, the driver will fail to load and  */
    /* a error entry is made in the event viewer to reflect this */

    /* Get System Directory. This should be something like c:\windows\system32 or  */
    /* c:\winnt\system32 with a Maximum Character lenght of 20. As we have a       */
    /* buffer of 80 bytes and a string of 24 bytes to append, we can go for a max  */
    /* of 55 bytes */

    if (!GetSystemDirectory(DriverFileName, 55))
        {
			MessageBox(NULL,"Failed to get System Directory. Is System Directory Path > 55 Characters?\nPlease manually copy driver to your system32/driver directory.",
				"Kport-DLL",MB_ICONINFORMATION);
			
        }

	LPSTR buffer = NULL;
    /* Append our Driver Name */
    lstrcat(DriverFileName,"\\Drivers\\kioport.sys");
	wsprintf(buffer,"Copying driver to %s",DriverFileName);
	::MessageBox(NULL,buffer,"Kport-DLL",MB_ICONINFORMATION);

    /* Copy Driver to System32/drivers directory. This fails if the file doesn't exist. */
	LPSTR szcopy = NULL;
    if (!CopyFile("kioport.sys", DriverFileName, FALSE))
        {
			
			wsprintf(szcopy,"Failed to copy driver to %s\nPlease manually copy driver to your system32/driver directory."
				,DriverFileName);
			MessageBox(NULL,szcopy,"Kport-DLL",MB_ICONINFORMATION);
		}
	else
		MessageBox(NULL,"Copiado satisfactoriamente.","Kport-DLL",MB_ICONINFORMATION);

    /* Open Handle to Service Control Manager */
    SchSCManager = OpenSCManager (NULL,                   /* machine (NULL == local)  */
                                  NULL,                   /* database (NULL == default)*/ 
                                  SC_MANAGER_ALL_ACCESS); /* access required */
		 
    /* Create Service/Driver - This adds the appropriate registry keys in 
    /* HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services - It doesn't  
    /* care if the driver exists, or if the path is correct.              */

    schService = CreateService (SchSCManager,                      /* SCManager database*/ 
                                "KioPort",                        /* name of service */
                                "KioPort",                        /* name to display */
                                SERVICE_ALL_ACCESS,                /* desired access */
                                SERVICE_KERNEL_DRIVER,             /* service type */
                                SERVICE_DEMAND_START,              /* start type */
                                SERVICE_ERROR_NORMAL,              /* error control type */
                                "System32\\Drivers\\kioport.sys", /* service's binary */
                                NULL,                              /* no load ordering group */
                                NULL,                              /* no tag identifier*/
                                NULL,                              /* no dependencies */
                                NULL,                              /* LocalSystem account*/
                                NULL                               /* no password */
                                );		

    if (schService == NULL) {
         err = GetLastError();
         if (err == ERROR_SERVICE_EXISTS)
			 MessageBox(NULL,"Driver already exists. No action taken.","Kport-DLL",MB_ICONINFORMATION);
               
         else MessageBox(NULL,"Unknown error while creating Service.","Kport-DLL",MB_ICONINFORMATION);
    }
    else MessageBox(NULL,"Driver successfully installed.\n","Kport-DLL",MB_ICONINFORMATION);
			
    /* Close Handle to Service Control Manager */
    CloseServiceHandle (schService);
}

void APIENTRY ClosePort(void)
{
  CloseHandle(hKport);
}
///Function Helper Beta function no implement/////////////////////////////////////////////////////////////////////////////////////////
/*BOOL APIENTRY Is_Win2000_Professional () 
{
   OSVERSIONINFOEX osvi;
   DWORDLONG dwlConditionMask = 0;

   // Initialize the OSVERSIONINFOEX structure.

   ZeroMemory(&osvi, sizeof(OSVERSIONINFOEX));
   osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEX);
   osvi.dwMajorVersion = 5;
   osvi.wProductType = VER_NT_WORKSTATION;

   // Initialize the condition mask.

   VER_SET_CONDITION( dwlConditionMask, VER_MAJORVERSION, 
      VER_GREATER_EQUAL );
   VER_SET_CONDITION( dwlConditionMask, VER_PRODUCT_TYPE, 
      VER_EQUAL );

   // Perform the test.

   return VerifyVersionInfo(
      &osvi, 
      VER_MAJORVERSION | VER_PRODUCT_TYPE,
      dwlConditionMask);
}
*/

/////////////////////////////////////////////////////////////////////////////////////////////