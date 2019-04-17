#include "interception.h"
//MUST ADD dll to this directory and add it to project build and general build options
//dll can be rebuilt in vs project
#include <time.h>
#include <iostream>
#include <deque>
#include <climits>
#include <chrono>
#include <thread>

using namespace std;

enum ScanCode
{
    //Light A
    SCANCODE_1 = 0x02,
    SCANCODE_2 = 0x03,
    SCANCODE_3 = 0x04,
    SCANCODE_4 = 0x05,

    //Heavy A
    SCANCODE_5 = 0x06,
    SCANCODE_6 = 0x07,
    SCANCODE_7 = 0x08,
    SCANCODE_8 = 0x09,

    //Light B
    SCANCODE_9 = 0x0A,
    SCANCODE_0 = 0x0B,
    SCANCODE_MINUS = 0x0C,
    SCANCODE_EQUALS = 0x0D,

    //Heavy B
    SCANCODE_NUMPLUS = 0x4E,
    SCANCODE_NUMSTAR = 0x37,
    SCANCODE_TILDE = 0x29,
    SCANCODE_BKSL = 0x2B,

    SCANCODE_ESC = 0x01,
    SCANCODE_Q = 0x10,
    SCANCODE_W = 0x11,
    SCANCODE_E = 0x12,
    SCANCODE_A = 0x1E,
    SCANCODE_S = 0x1F,
    SCANCODE_D = 0x20,
    SCANCODE_U = 0x16,
    SCANCODE_I = 0x17,
    SCANCODE_O = 0x18,
    SCANCODE_TAB = 0x0F,
    SCANCODE_CAPS = 0x3A,
    SCANCODE_SPACE = 0x39,
    SCANCODE_LALT = 0x38
};

InterceptionKeyStroke nothing = {};
InterceptionMouseStroke mnothing = {};
InterceptionKeyStroke ctrl_down = {0x1D, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke alt_down  = {0x38, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke del_down  = {0x53, INTERCEPTION_KEY_DOWN | INTERCEPTION_KEY_E0};
InterceptionKeyStroke w_down = {SCANCODE_W, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke w_up = {SCANCODE_W, INTERCEPTION_KEY_UP};
InterceptionKeyStroke a_down = {SCANCODE_A, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke a_up = {SCANCODE_A, INTERCEPTION_KEY_UP};
InterceptionKeyStroke s_down = {SCANCODE_S, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke s_up = {SCANCODE_S, INTERCEPTION_KEY_UP};
InterceptionKeyStroke d_down = {SCANCODE_D, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke d_up = {SCANCODE_D, INTERCEPTION_KEY_UP};
InterceptionKeyStroke e_down = {SCANCODE_E, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke e_up = {SCANCODE_E, INTERCEPTION_KEY_UP};
InterceptionKeyStroke q_down = {SCANCODE_Q, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke q_up = {SCANCODE_Q, INTERCEPTION_KEY_UP};
InterceptionKeyStroke u_down = {SCANCODE_U, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke i_down = {SCANCODE_I, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke o_down = {SCANCODE_O, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke caps_down = {SCANCODE_CAPS, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke caps_up = {SCANCODE_CAPS, INTERCEPTION_KEY_UP};
InterceptionKeyStroke space_down = {SCANCODE_SPACE, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke space_up = {SCANCODE_SPACE, INTERCEPTION_KEY_UP};
InterceptionKeyStroke lalt_down = {SCANCODE_LALT, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke lalt_up = {SCANCODE_LALT, INTERCEPTION_KEY_UP};
InterceptionKeyStroke tab_down = {SCANCODE_TAB, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke tab_up = {SCANCODE_TAB, INTERCEPTION_KEY_UP};

InterceptionKeyStroke up_press = w_down;
InterceptionKeyStroke up_release = w_up;
InterceptionKeyStroke left_press = a_down;
InterceptionKeyStroke left_release = a_up;
InterceptionKeyStroke right_press = d_down;
InterceptionKeyStroke right_release = d_up;
InterceptionKeyStroke down_press = s_down;
InterceptionKeyStroke down_release = s_up;

InterceptionKeyStroke modA_down = caps_down;
InterceptionKeyStroke modA_up = caps_up;

InterceptionKeyStroke buttonA_down = space_down;
InterceptionKeyStroke buttonB_down = lalt_down;
InterceptionKeyStroke buttonC_down = space_down;


const double xReqSpeedDef = 10;
const double yReqSpeedDef = 12;

double xReqSpeed = xReqSpeedDef;
double yReqSpeed = yReqSpeedDef;

const int xHitMaxDef = 15;
const int yHitMaxDef = 8;

int xHitMax = xHitMaxDef;
int yHitMax = yHitMaxDef;

int xHitMaxMod = (int)(xHitMaxDef/1.8);
int yHitMaxMod = (int)(yHitMaxDef/2);

int xReqSpeedMod = (int)(xHitMaxDef/2);
int yReqSpeedMod = (int)(yHitMaxDef/2);

int xHitCounter = 0;
int yHitCounter = 0;

bool mouseX(double dist, deque<double> * distX_sequence, deque<double> * mouseMoveX_sequence, deque<double> * mouseMoveY_sequence)
{
    if((dist > xReqSpeed) || (dist <= -1*xReqSpeed))
    {
        xHitCounter++;
        if(xHitCounter == xHitMax)
        {
            xHitCounter = 0;
            xHitMax -= xHitMaxMod;
            yHitMax = yHitMaxDef;
            mouseMoveX_sequence->pop_front();
            mouseMoveX_sequence->push_back(dist);
            int size = distX_sequence->size();
            distX_sequence->clear();
            mouseMoveY_sequence->clear();
            for(int i = 0; i < size; i++) {
                distX_sequence->push_back(INT_MAX);
                mouseMoveY_sequence->push_back(0);
            }
            cout << "mouseX: (" << (*mouseMoveX_sequence)[0] << " " << (*mouseMoveX_sequence)[size-5] << " " << (*mouseMoveX_sequence)[size-4] << " " << (*mouseMoveX_sequence)[size-3] << " " << (*mouseMoveX_sequence)[size-2] << " " << (*mouseMoveX_sequence)[size-1] << ")" << endl;
        }
        return true;
    }
    return false;
}

bool mouseY(double dist, deque<double> * distY_sequence, deque<double> * mouseMoveY_sequence, deque<double> * mouseMoveX_sequence)
{
    if(dist >= yReqSpeed || dist < -1*yReqSpeed)
    {
        yHitCounter++;
        //cout << yHitMaxMod << endl;
        if(yHitCounter == yHitMax)
        {
            if(dist < -1*yReqSpeed)
            {
                yHitCounter = (int)yHitMaxDef*0.25;
            }
            else
            {
                yHitCounter = -1*(int)yHitMaxDef*0.50;
            }
            //yHitMax = yHitMaxMod;
            xHitMax = xHitMaxDef;
            mouseMoveY_sequence->pop_front();
            mouseMoveY_sequence->push_back(dist);
            int size = distY_sequence->size();
            distY_sequence->clear();
            mouseMoveX_sequence->clear();
            for(int i = 0; i < size; i++) {
                distY_sequence->push_back(INT_MAX);
                mouseMoveX_sequence->push_back(0);
            }
            cout << "mouseY: (" << (*mouseMoveY_sequence)[0] << " " << (*mouseMoveY_sequence)[size-5] << " " << (*mouseMoveY_sequence)[size-4] << " " << (*mouseMoveY_sequence)[size-3] << " " << (*mouseMoveY_sequence)[size-2] << " " << (*mouseMoveY_sequence)[size-1] << ")" << endl;
        }
        return true;
    }
    return false;
}

bool operator == (const InterceptionKeyStroke &first, const InterceptionKeyStroke &second)
{
    return first.code == second.code && first.state == second.state;
}

bool operator != (const InterceptionKeyStroke &first, const InterceptionKeyStroke &second)
{
    return !(first == second);
}

int main()
{
    using namespace std;

    InterceptionContext context;
    InterceptionDevice device;
    InterceptionStroke new_stroke;
    InterceptionKeyStroke last_stroke;
    InterceptionMouseStroke mlast_stroke;

    deque<InterceptionKeyStroke> stroke_sequence;
    deque<InterceptionMouseStroke> mstroke_sequence;
    deque<double> time_sequence;
    deque<double> distX_sequence;
    deque<double> distY_sequence;
    deque<double> mouseMoveX_sequence;
    deque<double> mouseMoveY_sequence;

    int kbBufferSize = 6;
    for(int i = 0; i < kbBufferSize; i++) {
        stroke_sequence.push_back(nothing);
        mstroke_sequence.push_back(mnothing);
    }

    int size = stroke_sequence.size();

    for(int i = 0; i < size; i++) {
        time_sequence.push_back(INT_MAX);
        distX_sequence.push_back(0);
        distY_sequence.push_back(0);
        mouseMoveX_sequence.push_back(0);
        mouseMoveY_sequence.push_back(0);
    }

    cout << "size: " << time_sequence.size() << endl;

    context = interception_create_context();
    int mod = 0;
    interception_set_filter(context, interception_is_keyboard, INTERCEPTION_FILTER_KEY_ALL);
    interception_set_filter(context, interception_is_mouse, INTERCEPTION_FILTER_MOUSE_MOVE);
    double oldTime = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    double oldDistX, oldDistY = 0;
    int combo = 1500;
    while(interception_receive(context, device = interception_wait(context), (InterceptionStroke *)&new_stroke, 1) > 0)
    {
        if(interception_is_mouse(device))
        {
            InterceptionMouseStroke &mstroke = *(InterceptionMouseStroke *) &new_stroke;

            if(!(mstroke.flags & INTERCEPTION_MOUSE_MOVE_ABSOLUTE) && mod)
            {
                double newDistX = mstroke.x;
                double newDistY = mstroke.y;
                double diffX = newDistX-oldDistX;
                double diffY = newDistY-oldDistY;

                bool added = false;
                bool xAxis = mouseX(diffX, &distX_sequence, &mouseMoveX_sequence, &mouseMoveY_sequence);
                bool yAxis = mouseY(diffY, &distY_sequence, &mouseMoveY_sequence, &mouseMoveX_sequence);
                if(xAxis)
                {
                    distX_sequence.pop_front();
                    distX_sequence.push_back(diffX);
                }
                else if(yAxis)
                {
                    distY_sequence.pop_front();
                    distY_sequence.push_back(diffY);
                }
                if(xAxis || yAxis)
                {
                    double newTime = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
                    double diff = newTime-oldTime;
                    time_sequence.pop_front();
                    time_sequence.push_back(diff);
                    //cout << diff << endl;
                    oldTime = newTime;
                }
                else if(time_sequence[size-2] > combo)
                {
                    mouseMoveX_sequence.clear();
                    mouseMoveY_sequence.clear();
                    distX_sequence.clear();
                    distY_sequence.clear();
                    for(int i = 0; i < size; i++) {
                        distX_sequence.push_back(0);
                        distY_sequence.push_back(0);
                        mouseMoveX_sequence.push_back(0);
                        mouseMoveY_sequence.push_back(0);
                        time_sequence[i] = INT_MAX;
                    }
                }
                if(!xAxis)
                {
                    xHitCounter = 0;
                    xHitMax = xHitMaxDef;
                }
                if(!yAxis)
                {
                    yHitCounter = 0;
                    yHitMax = yHitMaxDef;
                }
                mstroke.x = 0;
                mstroke.y = 0;
            }
            interception_send(context, device, &new_stroke, 1);
        }
        if(interception_is_keyboard(device))
        {

            InterceptionKeyStroke &kstroke = *(InterceptionKeyStroke *) &new_stroke;

            double newTime = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();

            if(kstroke == modA_down) {
                mod = 1;
                //cout << "MOD ON!" << endl;
            }

            double diff = newTime-oldTime;

            bool up = kstroke == up_press || kstroke == up_release;
            bool down = kstroke == down_press || kstroke == down_release;
            bool left = kstroke == left_press || kstroke == left_release;
            bool right = kstroke == right_press || kstroke == right_release;
            if(!up && !down && !left && !right)
            {
                stroke_sequence.pop_front();
                stroke_sequence.push_back(kstroke);
                time_sequence.pop_front();
                time_sequence.push_back(diff);
            }



            if(kstroke == modA_up) {
                mod = 0;
                //cout << "MOD OFF!" << endl;
                mouseMoveX_sequence.clear();
                mouseMoveY_sequence.clear();
                distX_sequence.clear();
                distY_sequence.clear();
                for(int i = 0; i < size; i++) {
                    distX_sequence.push_back(0);
                    distY_sequence.push_back(0);
                    mouseMoveX_sequence.push_back(0);
                    mouseMoveY_sequence.push_back(0);
                }
            }

            int executed = 0;

            //cout << "times: (" << time_sequence[0] << " " << time_sequence[size-5] << " " << time_sequence[size-4] << " " << time_sequence[size-3] << " " << time_sequence[size-2] << time_sequence[size-1] << ")" << endl;
            bool held = (last_stroke == modA_up); //|| (last_stroke == modB_up) || (last_stroke == modC_up);
            bool newStroke = last_stroke != kstroke;
            if(mod && (held || newStroke)) {
                xHitMax = xHitMaxDef;
                yHitMax = yHitMaxDef;
                last_stroke = kstroke;
                oldTime = newTime;

                //cout << "State: " << stroke_sequence[0].state << " " << stroke_sequence[1].state << " " << stroke_sequence[2].state << " " << stroke_sequence[3].state << " " << stroke_sequence[4].state << endl;
                //cout << "Keys: "  << stroke_sequence[0].code << " " << stroke_sequence[1].code << " " << stroke_sequence[2].code << " " << stroke_sequence[3].code << " " << stroke_sequence[5].code << endl;

                //L Up A
                if(mouseMoveY_sequence[size-1] < 0  && stroke_sequence[size-1] == buttonA_down) {
                    if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_1;
                        executed = 1;
                    }
                }
                //L Down A
                if(mouseMoveY_sequence[size-1] > 0  && stroke_sequence[size-1] == buttonA_down) {
                    if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_2;
                        executed = 1;
                    }
                }
                //L Left A
                if(mouseMoveX_sequence[size-1] < 0  && stroke_sequence[size-1] == buttonA_down) {
                    if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_3;
                        executed = 1;
                    }
                }
                //L Right A
                if(mouseMoveX_sequence[size-1] > 0  && stroke_sequence[size-1] == buttonA_down) {
                    if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_4;
                        executed = 1;
                    }
                }

                //H Up A
                if(mouseMoveY_sequence[size-2] < 0 && mouseMoveY_sequence[size-1] < 0  && stroke_sequence[size-1] == buttonA_down) {
                    if(time_sequence[size-3] < combo && time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_5;
                        executed = 1;
                    }
                }
                //H Down A
                if(mouseMoveY_sequence[size-2] > 0 && mouseMoveY_sequence[size-1] > 0  && stroke_sequence[size-1] == buttonA_down) {
                    if(time_sequence[size-3] < combo && time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_6;
                        executed = 1;
                    }
                }
                //H Left A
                if(mouseMoveX_sequence[size-2] < 0 && mouseMoveX_sequence[size-1] < 0 && stroke_sequence[size-1] == buttonA_down) {
                    if(time_sequence[size-3] < combo && time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_7;
                        executed = 1;
                    }
                }
                //H Right A
                if(mouseMoveX_sequence[size-2] > 0 && mouseMoveX_sequence[size-1] > 0  && stroke_sequence[size-1] == buttonA_down) {
                    if(time_sequence[size-3] < combo && time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_8;
                        executed = 1;
                    }
                }

                //L Up B
                if(mouseMoveY_sequence[size-1] < 0  && stroke_sequence[size-1] == buttonB_down) {
                    if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_9;
                        executed = 1;
                    }
                }
                //L Down B
                if(mouseMoveY_sequence[size-1] > 0  && stroke_sequence[size-1] == buttonB_down) {
                    if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_0;
                        executed = 1;
                    }
                }
                //L Left B
                if(mouseMoveX_sequence[size-1] < 0  && stroke_sequence[size-1] == buttonB_down) {
                    if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_MINUS;
                        executed = 1;
                    }
                }
                //L Right B
                if(mouseMoveX_sequence[size-1] > 0  && stroke_sequence[size-1] == buttonB_down) {
                    if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_EQUALS;
                        executed = 1;
                    }
                }

                //H Up B
                if(mouseMoveY_sequence[size-2] < 0 && mouseMoveY_sequence[size-1] < 0  && stroke_sequence[size-1] == buttonB_down) {
                    if(time_sequence[size-3] < combo && time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_NUMPLUS;
                        executed = 1;
                    }
                }
                //H Down B
                if(mouseMoveY_sequence[size-2] > 0 && mouseMoveY_sequence[size-1] > 0  && stroke_sequence[size-1] == buttonB_down) {
                    if(time_sequence[size-3] < combo && time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_NUMSTAR;
                        executed = 1;
                    }
                }
                //H Left B
                if(mouseMoveX_sequence[size-2] < 0 && mouseMoveX_sequence[size-1] < 0 && stroke_sequence[size-1] == buttonB_down) {
                    if(time_sequence[size-3] < combo && time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_TILDE;
                        executed = 1;
                    }
                }
                //H Right B
                if(mouseMoveX_sequence[size-2] > 0 && mouseMoveX_sequence[size-1] > 0  && stroke_sequence[size-1] == buttonB_down) {
                    if(time_sequence[size-3] < combo && time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_BKSL;
                        executed = 1;
                    }
                }

                //send up stroke unconditionally
                if(last_stroke.state == INTERCEPTION_KEY_UP) {
                    interception_send(context, device, (InterceptionStroke *)&last_stroke, 1);
                    if(executed) {
                        last_stroke.state = stroke_sequence[size-2].state;
                        last_stroke.code = stroke_sequence[size-2].code;
                        interception_send(context, device, (InterceptionStroke *)&stroke_sequence[size-2], 1);
                    }
                }
                if(executed) {
                    int size = stroke_sequence.size();
                    for(int i = 0; i < size-2; i++) {
                        stroke_sequence[i] = nothing;
                        time_sequence[i] = INT_MAX;
                    }
                    //this line makes it so that the last stroke made to complete the command is sent BEFORE the command is sent
                    //interception_send(context, device, (InterceptionStroke *)&last_stroke, 1);
                    kstroke.state = INTERCEPTION_KEY_DOWN;
                    interception_send(context, device, (InterceptionStroke *)&kstroke, 1);
                    //sleep time too low will cause key to not be send
                    this_thread::sleep_for(chrono::milliseconds(100));
                    kstroke.state = INTERCEPTION_KEY_UP;
                    interception_send(context, device, (InterceptionStroke *)&kstroke, 1);
                    //this line makes it so that the last stroke made to complete the command is sent AFTER the command is sent
                    //interception_send(context, device, (InterceptionStroke *)&last_stroke, 1);
                }
                mouseMoveX_sequence.clear();
                mouseMoveY_sequence.clear();
                distX_sequence.clear();
                distY_sequence.clear();
                for(int i = 0; i < size; i++) {
                    distX_sequence.push_back(0);
                    distY_sequence.push_back(0);
                    mouseMoveX_sequence.push_back(0);
                    mouseMoveY_sequence.push_back(0);
                }
            }
            else if (kstroke.state == INTERCEPTION_KEY_UP || !mod) {
                interception_send(context, device, (InterceptionStroke *)&kstroke, 1);
            }
            //allows keys to pass through even if mod is pressed
            if (kstroke.state == INTERCEPTION_KEY_DOWN && mod && kstroke != modA_down) {
                interception_send(context, device, (InterceptionStroke *)&kstroke, 1);
            }
        }
    }
    interception_destroy_context(context);

    return 0;
}