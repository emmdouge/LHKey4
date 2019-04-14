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
    SCANCODE_1 = 0x02,
    SCANCODE_2 = 0x03,
    SCANCODE_3 = 0x04,
    SCANCODE_4 = 0x05,
    SCANCODE_5 = 0x06,
    SCANCODE_6 = 0x07,
    SCANCODE_7 = 0x08,
    SCANCODE_8 = 0x09,
    SCANCODE_9 = 0x0A,
    SCANCODE_0 = 0x0B,
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

InterceptionKeyStroke up_press = q_down;
InterceptionKeyStroke up_release = q_up;
InterceptionKeyStroke left_press = caps_down;
InterceptionKeyStroke left_release = caps_up;
InterceptionKeyStroke right_press = d_down;
InterceptionKeyStroke right_release = d_up;
InterceptionKeyStroke down_press = a_down;
InterceptionKeyStroke down_release = a_up;

InterceptionKeyStroke modA_down = tab_down;
InterceptionKeyStroke modA_up = tab_up;
InterceptionKeyStroke modB_down = space_down;
InterceptionKeyStroke modB_up = space_up;
InterceptionKeyStroke modC_down = lalt_down;
InterceptionKeyStroke modC_up = lalt_up;

InterceptionKeyStroke buttonA_down = w_down;
InterceptionKeyStroke buttonB_down = s_down;
InterceptionKeyStroke buttonC_down = e_down;



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
    InterceptionKeyStroke new_stroke, last_stroke;

    deque<InterceptionKeyStroke> stroke_sequence;
    deque<double> time_sequence;

    int kbBufferSize = 6;
    for(int i = 0; i < kbBufferSize; i++) {
        stroke_sequence.push_back(nothing);
    }

    int size = stroke_sequence.size();

    for(int i = 0; i < size; i++) {
        time_sequence.push_back(INT_MAX);
    }

    cout << "size: " << time_sequence.size() << endl;

    context = interception_create_context();
    int mod = 0;
    interception_set_filter(context, interception_is_keyboard, INTERCEPTION_FILTER_KEY_ALL);
    double oldTime = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    int combo = 200;
    while(interception_receive(context, device = interception_wait(context), (InterceptionStroke *)&new_stroke, 1) > 0)
    {
        double newTime = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();

        if(new_stroke == modA_down) {
            mod = 1;
            cout << "MOD ON!" << endl;
        }

        stroke_sequence.pop_front();
        stroke_sequence.push_back(new_stroke);

        double diff = newTime-oldTime;

        time_sequence.pop_front();
        time_sequence.push_back(diff);

        if(new_stroke == modA_up) {
            mod = 0;
            cout << "MOD OFF!" << endl;
        }

        int executed = 0;

        cout << "times: (" << time_sequence[0] << " " << time_sequence[size-5] << " " << time_sequence[size-4] << " " << time_sequence[size-3] << " " << time_sequence[size-2] << time_sequence[size-1] << ")" << endl;

        if(mod) {
            last_stroke = new_stroke;
            oldTime = newTime;
            //cw
            if(stroke_sequence[size-2] == modA_down && stroke_sequence[size-1] == up_press) {
                if(time_sequence[size-1] < combo && time_sequence[size-1] < combo) {
                    new_stroke.code = SCANCODE_3;
                    executed = 1;
                }
            }
            //ca
            if(stroke_sequence[size-2] == modA_down && stroke_sequence[size-1] == left_press) {
                if(time_sequence[size-1] < combo && time_sequence[size-1] < combo) {
                    new_stroke.code = SCANCODE_1;
                    executed = 1;
                }
            }
            //cs
            if(stroke_sequence[size-2] == modA_down && stroke_sequence[size-1] == down_press) {
                if(time_sequence[size-1] < combo && time_sequence[size-1] < combo) {
                    new_stroke.code = SCANCODE_4;
                    executed = 1;
                }
            }
            //cd
            if(stroke_sequence[size-2] == modA_down && stroke_sequence[size-1] == right_press) {
                if(time_sequence[size-1] < combo && time_sequence[size-1] < combo) {
                    new_stroke.code = SCANCODE_2;
                    executed = 1;
                }
            }
            //cSpace
            if(stroke_sequence[size-2] == modA_down && stroke_sequence[size-1] == modB_down) {
                if(time_sequence[size-1] < combo && time_sequence[size-1] < combo) {
                    new_stroke.code = SCANCODE_5;
                    executed = 1;
                }
            }
            //cAlt
            if(stroke_sequence[size-2] == modA_down && stroke_sequence[size-1] == modC_down) {
                if(time_sequence[size-1] < combo && time_sequence[size-1] < combo) {
                    new_stroke.code = SCANCODE_6;
                    executed = 1;
                }
            }
            //ccw
            if(stroke_sequence[size-4] == modA_down && stroke_sequence[size-3] == modA_up && stroke_sequence[size-2] == modA_down && stroke_sequence[size-1] == up_press) {
                if(time_sequence[size-3] < combo && time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                    new_stroke.code = SCANCODE_7;
                    executed = 1;
                }
            }
            //ccs
            if(stroke_sequence[size-4] == modA_down && stroke_sequence[size-3] == modA_up && stroke_sequence[size-2] == modA_down && stroke_sequence[size-1] == down_press) {
                if(time_sequence[size-3] < combo && time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                    new_stroke.code = SCANCODE_8;
                    executed = 1;
                }
            }
            //cca
            if(stroke_sequence[size-4] == modA_down && stroke_sequence[size-3] == modA_up && stroke_sequence[size-2] == modA_down && stroke_sequence[size-1] == left_press) {
                if(time_sequence[size-3] < combo && time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                    new_stroke.code = SCANCODE_9;
                    executed = 1;
                }
            }
            //ccd
            if(stroke_sequence[size-4] == modA_down && stroke_sequence[size-3] == modA_up && stroke_sequence[size-2] == modA_down && stroke_sequence[size-1] == right_press) {
                if(time_sequence[size-3] < combo && time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                    new_stroke.code = SCANCODE_0;
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
                }
                interception_send(context, device, (InterceptionStroke *)&last_stroke, 1);
                new_stroke.state = INTERCEPTION_KEY_DOWN;
                interception_send(context, device, (InterceptionStroke *)&new_stroke, 1);
                //sleep time too low will cause key to not be send
                this_thread::sleep_for(chrono::milliseconds(100));
                new_stroke.state = INTERCEPTION_KEY_UP;
                interception_send(context, device, (InterceptionStroke *)&new_stroke, 1);
                interception_send(context, device, (InterceptionStroke *)&last_stroke, 1);
            }
        }
        else if (new_stroke.state == INTERCEPTION_KEY_UP || !mod) {
            interception_send(context, device, (InterceptionStroke *)&new_stroke, 1);
        }
        cout << "State: " << stroke_sequence[0].state << " " << stroke_sequence[1].state << " " << stroke_sequence[2].state << " " << stroke_sequence[3].state << " " << stroke_sequence[4].state << endl;
        cout << "Keys: "  << stroke_sequence[0].code << " " << stroke_sequence[1].code << " " << stroke_sequence[2].code << " " << stroke_sequence[3].code << " " << stroke_sequence[5].code << endl;
    }

    interception_destroy_context(context);

    return 0;
}
