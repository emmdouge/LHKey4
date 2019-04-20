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


const double xReqSpeedDef = 3;
const double yReqSpeedDef = 3;

double xReqSpeed = xReqSpeedDef;
double yReqSpeed = yReqSpeedDef;

const int xHitMaxDef = 12;
const int yHitMaxDef = 12;
const int rollMaxDef = 3;

int xHitMax = xHitMaxDef;
int yHitMax = yHitMaxDef;

int xHitCounter = 0;
int yHitCounter = 0;
int rollCounter = 0;

bool mouseX(double dist, deque<double> * distX_sequence, deque<double> * mouseMoveX_sequence, deque<double> * mouseMoveY_sequence)
{
    if((dist > xReqSpeed) || (dist < -1*xReqSpeed))
    {
        xHitCounter++;
        if(xHitCounter == xHitMax)
        {
            if(dist < -1*xReqSpeed)
            {
                xHitCounter = -1*(int)xHitMaxDef*0.25;
            }
            else
            {
                xHitCounter = -1*(int)xHitMaxDef*0.20;
            }
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
            //up
            if(dist < -1*yReqSpeed)
            {
                yHitCounter = (int)yHitMaxDef*0.44;
            }
            //down
            else
            {
                yHitCounter = (int)yHitMaxDef*0.22;
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

bool roll(double rolling, deque<double> * roll_sequence)
{
    if(rolling > 0 || rolling < 0)
    {
        rollCounter++;
        if(rollCounter == rollMaxDef)
        {
            int size = roll_sequence->size();
            roll_sequence->pop_front();
            roll_sequence->push_back(rolling);
            cout << "roll: (" << (*roll_sequence)[0] << " " << (*roll_sequence)[size-5] << " " << (*roll_sequence)[size-4] << " " << (*roll_sequence)[size-3] << " " << (*roll_sequence)[size-2] << " " << (*roll_sequence)[size-1] << ")" << endl;
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

bool operator == (const InterceptionMouseStroke &first, const InterceptionMouseStroke &second)
{
    return first.flags == second.flags && first.state == second.state;
}

bool operator != (const InterceptionMouseStroke &first, const InterceptionMouseStroke &second)
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

    deque<InterceptionKeyStroke> stroke_sequence;
    deque<InterceptionMouseStroke> mstroke_sequence;
    deque<double> time_sequence;
    deque<double> distX_sequence;
    deque<double> distY_sequence;
    deque<double> mouseMoveX_sequence;
    deque<double> mouseMoveY_sequence;
    deque<double> roll_sequence;

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
        roll_sequence.push_back(0);
    }

    cout << "size: " << time_sequence.size() << endl;

    context = interception_create_context();
    int mod = 0;
    interception_set_filter(context, interception_is_keyboard, INTERCEPTION_FILTER_KEY_ALL);
    interception_set_filter(context, interception_is_mouse, INTERCEPTION_FILTER_MOUSE_MOVE | INTERCEPTION_FILTER_MOUSE_WHEEL |
        INTERCEPTION_FILTER_MOUSE_LEFT_BUTTON_DOWN | INTERCEPTION_FILTER_MOUSE_RIGHT_BUTTON_DOWN
    );
    InterceptionDevice kbDevice;
    double oldTime = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    double oldDistX = 0, oldDistY = 0;
    int combo = 2000;
    while(interception_receive(context, device = interception_wait(context), (InterceptionStroke *)&new_stroke, 1) > 0)
    {

        int executed = 0;
        InterceptionKeyStroke &kstroke = *(InterceptionKeyStroke *) &new_stroke;
        if(interception_is_mouse(device))
        {
            InterceptionMouseStroke &mstroke = *(InterceptionMouseStroke *) &new_stroke;
            int wheel = !(mstroke.flags & INTERCEPTION_MOUSE_WHEEL);
            int mouse = !(mstroke.flags & INTERCEPTION_MOUSE_MOVE_ABSOLUTE);
            if(mouse && mod)
            {
                double newDistX = mstroke.x;
                double newDistY = mstroke.y;
                double diffX = newDistX-oldDistX;
                double diffY = newDistY-oldDistY;

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
                    //H Left
                    if(mouseMoveX_sequence[size-2] < 0 && mouseMoveX_sequence[size-1] < 0) {
                        if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                            cout << "key7" << endl;
                            kstroke.code = SCANCODE_7;
                            kstroke.information = 0;
                            executed = 1;
                            xHitMax = xHitMaxDef;
                        }
                    }
                    //H Up
                    if(mouseMoveY_sequence[size-2] < 0 && mouseMoveY_sequence[size-1] < 0) {
                        if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                            kstroke.code = SCANCODE_5;
                            kstroke.information = 0;
                            executed = 1;
                            yHitMax = yHitMaxDef;
                        }
                    }
                    //H Down
                    if(mouseMoveY_sequence[size-2] > 0 && mouseMoveY_sequence[size-1] > 0) {
                        if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                            kstroke.code = SCANCODE_6;
                            kstroke.information = 0;
                            executed = 1;
                            yHitMax = yHitMaxDef;
                        }
                    }

                    //H Right
                    if(mouseMoveX_sequence[size-2] > 0 && mouseMoveX_sequence[size-1] > 0) {
                        if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                            kstroke.code = SCANCODE_8;
                            kstroke.information = 0;
                            executed = 1;
                            xHitMax = xHitMaxDef;
                        }
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
            if(wheel && mod)
            {
                bool validRoll = roll(mstroke.rolling, &roll_sequence);
                if(validRoll)
                {
                    double newTime = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
                    double diff = newTime-oldTime;
                    time_sequence.pop_front();
                    time_sequence.push_back(diff);
                    //cout << "do a barrel roll!" << endl;
                    oldTime = newTime;
                    int rollUp = roll_sequence[size-1] > 0;
                    int rollDown = roll_sequence[size-1] < 0;

//                    if(rollUp && mouseMoveX_sequence[size-1] == 0 && mouseMoveY_sequence[size-1] == 0)
//                    {
//                        kstroke.code = SCANCODE_9;
//                        kstroke.information = 0;
//                        executed = 1;
//                    }
//                    else if(rollDown && mouseMoveX_sequence[size-1] == 0 && mouseMoveY_sequence[size-1] == 0)
//                    {
//                        kstroke.code = SCANCODE_0;
//                        kstroke.information = 0;
//                        executed = 1;
//                    }

                    //L Up RollUp
                    if(mouseMoveY_sequence[size-1] < 0 && rollUp) {
                        if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                            kstroke.code = SCANCODE_9;
                            executed = 1;
                        }
                    }
                    //L Down RollUp
                    if(mouseMoveY_sequence[size-1] > 0 && rollUp) {
                        if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                            kstroke.code = SCANCODE_0;
                            executed = 1;
                        }
                    }
                    //L Left RollUp
                    if(mouseMoveX_sequence[size-1] < 0 && rollUp) {
                        if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                            kstroke.code = SCANCODE_MINUS;
                            executed = 1;
                        }
                    }
                    //L Right RollUp
                    if(mouseMoveX_sequence[size-1] > 0 && rollUp) {
                        if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                            kstroke.code = SCANCODE_EQUALS;
                            executed = 1;
                        }
                    }
                    //L Up RollDown
                    if(mouseMoveY_sequence[size-1] < 0 && rollDown) {
                        if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                            kstroke.code = SCANCODE_9;
                            executed = 1;
                        }
                    }
                    //L Down RollDown
                    if(mouseMoveY_sequence[size-1] > 0 && rollDown) {
                        if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                            kstroke.code = SCANCODE_0;
                            executed = 1;
                        }
                    }
                    //L Left RollDown
                    if(mouseMoveX_sequence[size-1] < 0 && rollDown) {
                        if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                            kstroke.code = SCANCODE_MINUS;
                            executed = 1;
                        }
                    }
                    //L Right RollDown
                    if(mouseMoveX_sequence[size-1] > 0 && rollDown) {
                        if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                            kstroke.code = SCANCODE_EQUALS;
                            executed = 1;
                        }
                    }
                }
            }
            if(mstroke.state == INTERCEPTION_MOUSE_LEFT_BUTTON_DOWN || mstroke.state == INTERCEPTION_MOUSE_RIGHT_BUTTON_DOWN)
            {
                double newTime = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
                double diff = newTime-oldTime;
                time_sequence.pop_front();
                time_sequence.push_back(diff);
                oldTime = newTime;
                int left = mstroke.state == INTERCEPTION_MOUSE_LEFT_BUTTON_DOWN;
                int right = mstroke.state == INTERCEPTION_MOUSE_RIGHT_BUTTON_DOWN;
                //L Up LC
                if(mouseMoveY_sequence[size-1] < 0 && left) {
                    if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_9;
                        executed = 1;
                    }
                }
                //L Down LC
                if(mouseMoveY_sequence[size-1] > 0 && left) {
                    if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_0;
                        executed = 1;
                    }
                }
                //L Left LC
                if(mouseMoveX_sequence[size-1] < 0 && left) {
                    if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_MINUS;
                        executed = 1;
                    }
                }
                //L Right LC
                if(mouseMoveX_sequence[size-1] > 0 && left) {
                    if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_EQUALS;
                        executed = 1;
                    }
                }
                //L Up RC
                if(mouseMoveY_sequence[size-1] < 0 && right) {
                    if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_9;
                        executed = 1;
                    }
                }
                //L Down RC
                if(mouseMoveY_sequence[size-1] > 0 && right) {
                    if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_0;
                        executed = 1;
                    }
                }
                //L Left RC
                if(mouseMoveX_sequence[size-1] < 0 && right) {
                    if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_MINUS;
                        executed = 1;
                    }
                }
                //L Right RC
                if(mouseMoveX_sequence[size-1] > 0 && right) {
                    if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_EQUALS;
                        executed = 1;
                    }
                }
            }
            if(executed)
            {
                xHitCounter = 0;
                yHitCounter = 0;
                rollCounter = 0;
                mouseMoveX_sequence.clear();
                mouseMoveY_sequence.clear();
                distX_sequence.clear();
                distY_sequence.clear();
                roll_sequence.clear();
                for(int i = 0; i < size; i++) {
                    distX_sequence.push_back(0);
                    distY_sequence.push_back(0);
                    mouseMoveX_sequence.push_back(0);
                    mouseMoveY_sequence.push_back(0);
                    roll_sequence.push_back(0);
                    time_sequence[i] = INT_MAX;
                }
                kstroke.state = INTERCEPTION_KEY_DOWN;
                interception_send(context, kbDevice, (InterceptionStroke *)&kstroke, 1);
                //sleep time too low will cause key to not be send
                this_thread::sleep_for(chrono::milliseconds(100));
                kstroke.state = INTERCEPTION_KEY_UP;
                interception_send(context, kbDevice, (InterceptionStroke *)&kstroke, 1);
            }
            if(!mod)
            {
                interception_send(context, device, (InterceptionStroke *)&mstroke, 1);
            }
        }
        if(interception_is_keyboard(device))
        {
            kbDevice = device;

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

            //cout << "times: (" << time_sequence[0] << " " << time_sequence[size-5] << " " << time_sequence[size-4] << " " << time_sequence[size-3] << " " << time_sequence[size-2] << time_sequence[size-1] << ")" << endl;
            bool held = (kstroke == modA_up); //|| (last_stroke == modB_up) || (last_stroke == modC_up);
            bool newStroke = last_stroke != kstroke;
            if((mod && (newStroke)) || held) {
                xHitMax = xHitMaxDef;
                yHitMax = yHitMaxDef;
                last_stroke = kstroke;
                oldTime = newTime;

                //cout << "State: " << stroke_sequence[0].state << " " << stroke_sequence[1].state << " " << stroke_sequence[2].state << " " << stroke_sequence[3].state << " " << stroke_sequence[4].state << endl;
                cout << "Keys: "  << stroke_sequence[0].code << " " << stroke_sequence[1].code << " " << stroke_sequence[2].code << " " << stroke_sequence[3].code << " " << stroke_sequence[5].code << endl;

                //L Up
                if(mouseMoveY_sequence[size-1] < 0  && stroke_sequence[size-1] == modA_up) {
                    if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_1;
                        executed = 1;
                    }
                }
                //L Down
                if(mouseMoveY_sequence[size-1] > 0  && stroke_sequence[size-1] == modA_up) {
                    if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_2;
                        executed = 1;
                    }
                }
                //L Left
                if(mouseMoveX_sequence[size-1] < 0  && stroke_sequence[size-1] == modA_up) {
                    if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_3;
                        executed = 1;
                    }
                }
                //L Right
                if(mouseMoveX_sequence[size-1] > 0  && stroke_sequence[size-1] == modA_up) {
                    if(time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                        kstroke.code = SCANCODE_4;
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

                //clear mouse inputs everytime a button is pressed while modded
                mouseMoveX_sequence.clear();
                mouseMoveY_sequence.clear();
                roll_sequence.clear();
                distX_sequence.clear();
                distY_sequence.clear();
                for(int i = 0; i < size; i++) {
                    distX_sequence.push_back(0);
                    distY_sequence.push_back(0);
                    mouseMoveX_sequence.push_back(0);
                    mouseMoveY_sequence.push_back(0);
                    roll_sequence.push_back(0);
                }
            }
            if(executed) {
                //put this line on individual commands is you want mod to be holdable to execute commands
                mod = 0;
                int size = stroke_sequence.size();
                for(int i = 0; i < size-2; i++) {
                    stroke_sequence[i] = nothing;
                    time_sequence[i] = INT_MAX;
                }
                //this line makes it so that the last stroke made to complete the command is sent BEFORE the command is sent
                //interception_send(context, device, (InterceptionStroke *)&last_stroke, 1);
                kstroke.state = INTERCEPTION_KEY_DOWN;
                interception_send(context, kbDevice, (InterceptionStroke *)&kstroke, 1);
                //sleep time too low will cause key to not be send
                this_thread::sleep_for(chrono::milliseconds(100));
                kstroke.state = INTERCEPTION_KEY_UP;
                interception_send(context, kbDevice, (InterceptionStroke *)&kstroke, 1);
                //this line makes it so that the last stroke made to complete the command is sent AFTER the command is sent
                //interception_send(context, device, (InterceptionStroke *)&last_stroke, 1);
                executed = 0;
            }
            if (kstroke.state == INTERCEPTION_KEY_UP && kstroke == modA_up) {
                mod = 0;
            }
            if (kstroke.state == INTERCEPTION_KEY_UP || !mod) {
                interception_send(context, kbDevice, (InterceptionStroke *)&kstroke, 1);
            }
            //keys to pass through even if mod is pressed and stops repeating modA presses
            else if (kstroke.state == INTERCEPTION_KEY_DOWN && mod && kstroke != modA_down) {
                //uncomment to unlock cam after key is pressed while mod is on
                //mod = 0;
                interception_send(context, kbDevice, (InterceptionStroke *)&kstroke, 1);
            }
        }
    }
    interception_destroy_context(context);

    return 0;
}
