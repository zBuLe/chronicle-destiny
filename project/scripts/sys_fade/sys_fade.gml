enum fade_state { none, out, in }

function Fade() constructor {
    state = fade_state.none;
    to    = -1;
    color = c_black;
    tick  = 0;
    rate  = 0.1;
    delay = 0.1;

    update = function() {
        switch (state) {
            case fade_state.in:
                if (tick > 0) { tick -= rate; }
                else { tick = 0; state = fade_state.none; }
                break;
            case fade_state.out:
                if (tick < 1 + delay) { tick += rate; }
                else { tick = 1; state = fade_state.none; room_goto(to); }
                break;
        }
    };

    draw = function() {
        if (state != fade_state.none) {
            draw_set_alpha(clamp(tick, 0, 1));
            draw_set_color(color);
            draw_rectangle(0, 0, SCREEN.width, SCREEN.height, false);
            draw_set_alpha(1);
        }
    };

    fade_to_room = function(_room, _color = c_black) {
        if (state == fade_state.none) {
            state = fade_state.out;
            color = _color;
            to    = _room;
        }
    };

    start = function() {
        tick  = 1;
        state = fade_state.in;
    };
}