#include "interception.h"
//MUST ADD dll to this directory and add it to project build and general build options
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
    SCANCODE_W = 0x11,
    SCANCODE_A = 0x1E,
    SCANCODE_S = 0x1F,
    SCANCODE_D = 0x20,
    SCANCODE_U = 0x16,
    SCANCODE_I = 0x17,
    SCANCODE_O = 0x18,
};

InterceptionKeyStroke nothing = {};
InterceptionKeyStroke ctrl_down = {0x1D, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke alt_down  = {0x38, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke del_down  = {0x53, INTERCEPTION_KEY_DOWN | INTERCEPTION_KEY_E0};
InterceptionKeyStroke w_down = {SCANCODE_W, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke a_down = {SCANCODE_A, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke a_up = {SCANCODE_A, INTERCEPTION_KEY_UP};
InterceptionKeyStroke s_down = {SCANCODE_S, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke s_up = {SCANCODE_S, INTERCEPTION_KEY_UP};
InterceptionKeyStroke d_down = {SCANCODE_D, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke d_up = {SCANCODE_D, INTERCEPTION_KEY_UP};
InterceptionKeyStroke u_down = {SCANCODE_U, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke i_down = {SCANCODE_I, INTERCEPTION_KEY_DOWN};
InterceptionKeyStroke o_down = {SCANCODE_O, INTERCEPTION_KEY_DOWN};

InterceptionKeyStroke buttonA_down = u_down;
InterceptionKeyStroke buttonB_down = i_down;
InterceptionKeyStroke buttonC_down = o_down;

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

    stroke_sequence.push_back(nothing);
    stroke_sequence.push_back(nothing);
    stroke_sequence.push_back(nothing);
    stroke_sequence.push_back(nothing);
    stroke_sequence.push_back(nothing);
    stroke_sequence.push_back(nothing);

    int size = stroke_sequence.size();

    for(int i = 0; i < size; i++) {
        time_sequence.push_back(INT_MAX);
    }

    cout << "size: " << time_sequence.size() << endl;

    context = interception_create_context();

    interception_set_filter(context, interception_is_keyboard, INTERCEPTION_FILTER_KEY_ALL);
    double oldTime = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    int combo = 200;
    while(interception_receive(context, device = interception_wait(context), (InterceptionStroke *)&new_stroke, 1) > 0)
    {

        stroke_sequence.pop_front();
        stroke_sequence.push_back(new_stroke);

        double newTime = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
        double diff = newTime-oldTime;

        time_sequence.pop_front();
        time_sequence.push_back(diff);
        int executed = 0;

        //cout << "times: (" << time_sequence[0] << " " << time_sequence[size-5] << " " << time_sequence[size-4] << " " << time_sequence[size-3] << " " << time_sequence[size-2] << " " << time_sequence[size-1] << ")" << endl;

        //qcf
        if(stroke_sequence[size-4] == s_down && (stroke_sequence[size-3] == d_down || stroke_sequence[size-3] == a_down) && stroke_sequence[4] == s_up) {
            if(time_sequence[size-3] < combo && time_sequence[size-2] < combo && time_sequence[size-1] < combo) {
                if(stroke_sequence[size-1] == buttonA_down) {
                    new_stroke.code = SCANCODE_1;
                    executed = 1;
                }
                else if(stroke_sequence[size-1] == buttonC_down) {
                    new_stroke.code = SCANCODE_5;
                    executed = 1;
                }
            }
        }
        //left dp
        else if(stroke_sequence[size-5] == a_down && stroke_sequence[size-4] == s_down && stroke_sequence[size-3] == a_up && stroke_sequence[size-2] == a_down) {
            if(time_sequence[size-4] < combo && time_sequence[size-3] < combo && time_sequence[size-2] < combo  && time_sequence[size-1] < combo) {
                if(stroke_sequence[size-1] == buttonA_down) {
                    new_stroke.code = SCANCODE_2;
                    executed = 1;
                }
                else if(stroke_sequence[size-1] == buttonC_down) {
                    new_stroke.code = SCANCODE_6;
                    executed = 1;
                }
            }
        }
        //right dp
        else if(stroke_sequence[size-5] == d_down && stroke_sequence[size-4] == s_down && stroke_sequence[size-3] == d_up && stroke_sequence[size-2] == d_down) {
            if(time_sequence[size-4] < combo && time_sequence[size-3] < combo && time_sequence[size-2] < combo  && time_sequence[size-1] < combo) {
                if(stroke_sequence[size-1] == buttonA_down) {
                    new_stroke.code = SCANCODE_2;
                    executed = 1;
                }
                else if(stroke_sequence[size-1] == buttonC_down) {
                    new_stroke.code = SCANCODE_6;
                    executed = 1;
                }
            }
        }
        //left kbd
        else if(stroke_sequence[size-5] == a_down && stroke_sequence[size-4] == a_up && stroke_sequence[size-3] == a_down && stroke_sequence[size-2] == s_down) {
            if(time_sequence[size-4] < combo && time_sequence[size-3] < combo && time_sequence[size-2] < combo  && time_sequence[size-1] < combo) {
                if(stroke_sequence[size-1] == buttonA_down) {
                    new_stroke.code = SCANCODE_3;
                    executed = 1;
                }
                else if(stroke_sequence[size-1] == buttonC_down) {
                    new_stroke.code = SCANCODE_7;
                    executed = 1;
                }
             }
        }
        //right kbd
        else if(stroke_sequence[size-5] == d_down && stroke_sequence[size-4] == d_up && stroke_sequence[size-3] == d_down && stroke_sequence[size-2] == s_down) {
            if(time_sequence[size-4] < combo && time_sequence[size-3] < combo && time_sequence[size-2] < combo  && time_sequence[size-1] < combo) {
                if(stroke_sequence[size-1] == buttonA_down) {
                    new_stroke.code = SCANCODE_3;
                    executed = 1;
                }
                else if(stroke_sequence[size-1] == buttonC_down) {
                    new_stroke.code = SCANCODE_7;
                    executed = 1;
                }
             }
        }
        //left ewgf
        else if(stroke_sequence[size-5] == a_down && stroke_sequence[size-4] == a_up && stroke_sequence[size-3] == s_down && stroke_sequence[size-2] == a_down) {
            if(time_sequence[size-4] < combo && time_sequence[size-3] < combo && time_sequence[size-2] < combo  && time_sequence[size-1] < combo) {
                if(stroke_sequence[size-1] == buttonA_down) {
                    new_stroke.code = SCANCODE_4;
                    executed = 1;
                }
                else if(stroke_sequence[size-1] == buttonC_down) {
                    new_stroke.code = SCANCODE_8;
                    executed = 1;
                }
             }
        }
        //right ewgf
        else if(stroke_sequence[size-5] == d_down && stroke_sequence[size-4] == d_up && stroke_sequence[size-3] == s_down && stroke_sequence[size-2] == d_down) {
            if(time_sequence[size-4] < combo && time_sequence[size-3] < combo && time_sequence[size-2] < combo  && time_sequence[size-1] < combo) {
                if(stroke_sequence[size-1] == buttonA_down) {
                    new_stroke.code = SCANCODE_4;
                    executed = 1;
                }
                else if(stroke_sequence[size-1] == buttonC_down) {
                    new_stroke.code = SCANCODE_8;
                    executed = 1;
                }
              }
        }
        //left hc
        else if(stroke_sequence[size-6] == a_down && stroke_sequence[size-5] == s_down && stroke_sequence[size-4] == a_up && stroke_sequence[size-3] == d_down && stroke_sequence[size-2] == s_up) {
            if(time_sequence[size-5] < combo && time_sequence[size-4] < combo && time_sequence[size-3] < combo && time_sequence[size-2] < combo  && time_sequence[size-1] < combo) {
                if(stroke_sequence[size-1] == buttonA_down) {
                    new_stroke.code = SCANCODE_9;
                    executed = 1;
                }
                else if(stroke_sequence[size-1] == buttonC_down) {
                    new_stroke.code = SCANCODE_9;
                    executed = 1;
                }
             }
        }
        //right hc
        else if(stroke_sequence[size-6] == d_down && stroke_sequence[size-5] == s_down && stroke_sequence[size-4] == d_up && stroke_sequence[size-3] == a_down && stroke_sequence[size-2] == s_up) {
            if(time_sequence[size-5] < combo && time_sequence[size-4] < combo && time_sequence[size-3] < combo && time_sequence[size-2] < combo  && time_sequence[size-1] < combo) {
                if(stroke_sequence[size-1] == buttonA_down) {
                    new_stroke.code = SCANCODE_0;
                    executed = 1;
                }
                else if(stroke_sequence[size-1] == buttonC_down) {
                    new_stroke.code = SCANCODE_0;
                    executed = 1;
                }
             }
        }
        if(executed) {
            stroke_sequence.clear();
            stroke_sequence.push_back(nothing);
            stroke_sequence.push_back(nothing);
            stroke_sequence.push_back(nothing);
            stroke_sequence.push_back(nothing);
            stroke_sequence.push_back(nothing);
            stroke_sequence.push_back(nothing);
            interception_send(context, device, (InterceptionStroke *)&new_stroke, 1);
            last_stroke.code = s_down.code;
            last_stroke.state = INTERCEPTION_KEY_UP;
            interception_send(context, device, (InterceptionStroke *)&last_stroke, 1);
            this_thread::sleep_for(chrono::milliseconds(100));
            last_stroke.code = new_stroke.code;
            last_stroke.state = INTERCEPTION_KEY_UP;
            interception_send(context, device, (InterceptionStroke *)&last_stroke, 1);
        }
        else {
            interception_send(context, device, (InterceptionStroke *)&new_stroke, 1);
        }
        last_stroke = new_stroke;
        oldTime = newTime;
    }

    interception_destroy_context(context);

    return 0;
}
