#include "interception.h"
//MUST ADD dll to this directory and add it to project build and general build options
#include <time.h>
#include <iostream>
#include <deque>
#include <climits>
#include <chrono>

using namespace std;

enum ScanCode
{
    SCANCODE_1 = 0x02,
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

    time_sequence.push_back(INT_MAX);
    time_sequence.push_back(INT_MAX);
    time_sequence.push_back(INT_MAX);
    time_sequence.push_back(INT_MAX);
    time_sequence.push_back(INT_MAX);
    time_sequence.push_back(INT_MAX);

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


        cout << "times: (" << time_sequence[0] << " " << time_sequence[1] << " " << time_sequence[2] << " " << time_sequence[3] << " " << time_sequence[4] << " " << time_sequence[5] << ")" << endl;

        if(stroke_sequence[2] == s_down && (stroke_sequence[3] == d_down || stroke_sequence[3] == a_down) && stroke_sequence[4] == s_up) {
            int executed = 0;
            if(time_sequence[3] < combo && time_sequence[4] < combo && time_sequence[5] < combo) {
                if(stroke_sequence[5] == buttonA_down) {
                    new_stroke.code = SCANCODE_1;
                }
                cout << "State: " << stroke_sequence[3].state << " " << stroke_sequence[2].state << " " << stroke_sequence[1].state << " " << stroke_sequence[1].state << endl;
                cout << "Keys: "  << stroke_sequence[2].code << " " << stroke_sequence[3].code << " " << stroke_sequence[2].code << " " << stroke_sequence[1].code << " " << stroke_sequence[1].code << endl;
                stroke_sequence.clear();
                stroke_sequence.push_back(nothing);
                stroke_sequence.push_back(nothing);
                stroke_sequence.push_back(nothing);
                stroke_sequence.push_back(nothing);
                stroke_sequence.push_back(nothing);
                stroke_sequence.push_back(nothing);
            }
        }
        interception_send(context, device, (InterceptionStroke *)&new_stroke, 1);
        last_stroke = new_stroke;
        oldTime = newTime;
    }

    interception_destroy_context(context);

    return 0;
}
