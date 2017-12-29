#include "interception.h"
//MUST ADD dll to this directory and add it to project build and general build options
#include<fstream>
#include<iostream>

enum ScanCode
{
    SCANCODE_X   = 0x2D, //45 in decimal
    SCANCODE_Y   = 0x15, //21 in decimal
    SCANCODE_ESC = 0x01
};

int main() {
    InterceptionContext context;
    InterceptionDevice device;
    InterceptionKeyStroke stroke;

    context = interception_create_context();

    interception_set_KBfilter(context, INTERCEPTION_FILTER_KEY_DOWN | INTERCEPTION_FILTER_KEY_UP);

    std::ofstream myfile;
    myfile.open ("example.txt");
    myfile << "Writing this to a file.\n";
    int t = 0;
    while(interception_receive(context, device = interception_wait(context), (InterceptionStroke *)&stroke, 1) > 0) {
        if(stroke.code == SCANCODE_X) {
            myfile<<"kb: "<<interception_is_keyboard<<" f:"<<(INTERCEPTION_FILTER_KEY_DOWN | INTERCEPTION_FILTER_KEY_UP)<<"\n";
            myfile<<"device: "<<device<<" context:"<<context<<" stroke: "<<&stroke<<" c:"<<stroke.code<<" i:"<<stroke.information<<" s:"<<stroke.state<<"\n";
            stroke.code = SCANCODE_Y;
            myfile<<"device: "<<device<<" context:"<<context<<" stroke: "<<&stroke<<" c:"<<stroke.code<<" i:"<<stroke.information<<" s:"<<stroke.state<<"\n";
            t++;
        }
        else if(stroke.code == SCANCODE_Y) {
            myfile<<"kb: "<<interception_is_keyboard<<"\n";
            myfile<<"device: "<<device<<" context:"<<context<<" stroke: "<<&stroke<<" c:"<<stroke.code<<" i:"<<stroke.information<<" s:"<<stroke.state<<"\n";
            stroke.code = SCANCODE_X;
            myfile<<"device: "<<device<<" context:"<<context<<" stroke: "<<&stroke<<" c:"<<stroke.code<<" i:"<<stroke.information<<" s:"<<stroke.state<<"\n";
            t++;
        }
        if(t == 4) {
            myfile.flush();
            myfile.close();
            interception_destroy_context(context);
            return 0;
        }
        interception_send(context, device, (InterceptionStroke *)&stroke, 1);
        interception_send(context, device, (InterceptionStroke *)&stroke, 1);
        interception_send(context, device, (InterceptionStroke *)&stroke, 1);


        if(stroke.code == SCANCODE_ESC) break;
    }
    myfile.flush();
    myfile.close();

    interception_destroy_context(context);

    return 0;
}
