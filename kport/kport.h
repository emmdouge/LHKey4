////////////////////////////////////////////////////////////////////////////
//	Copyright : Javier Palacios 2005
//	Ing.Electronic
//	U.T.N-F.R.C
//	Email :	jgp@argentina.com
//
//	This code may be used in compiled form in any way you desire. This
//	file may be redistributed unmodified by any means PROVIDING it is 
//	not sold for profit without the authors written consent, and 
//	providing that this notice and the authors name is included.
//
//	This file is provided 'as is' with no expressed or implied warranty.
//	The author accepts no liability if it causes any damage to your computer.
//
//	Do expect bugs.
//	Please let me know of any bugs/mods/improvements.
//	and I will try to fix/incorporate them into this file.
//	Enjoy!
//
//	Description : Kport Direct Acces IO Ports under Win NT/2000/XP 
////////////////////////////////////////////////////////////////////////////
#ifndef KPORT_H
#define KPORT_H
// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the KPORT_EXPORTS
// symbol defined on the command line. this symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// KPORT_API functions as being imported from a DLL, wheras this DLL sees symbols
// defined with this macro as being exported.
#include <windows.h>

#ifdef KPORT_EXPORTS
#define KPORT_API __declspec(dllexport)
#else
#define KPORT_API __declspec(dllimport)
#endif


#ifdef __cplusplus
extern "C" {
#endif
//////////////////////////////////////////////////////////////////////

// Returns a value from specific ports.
KPORT_API BYTE APIENTRY Inportb(WORD PortNum);

// Write a value to specific ports.
KPORT_API void APIENTRY Outportb(WORD PortNum, BYTE byte);

/////////////////////////////////////////////////////////////////////
#ifdef __cplusplus
}
#endif

#endif//end	 #ifndef KPORT_H
