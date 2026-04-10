// ── touch_zone ────────────────────────────────────────────────────────────────
enum touch_behavior { fixed, dynamic, adaptive }

function touch_zone(_cx = 0, _cy = 0, _size1 = 30, _size2 = undefined, _behavior = touch_behavior.adaptive) constructor {
    cx = _cx;
    cy = _cy;
    size1 = _size1;
    size2 = _size2;
    is_circle = (_size2 == undefined);

    tid = -1;
    on = false;

    ox = cx;
    oy = cy;
    origin_set = false;
    radius = _size1*2;
    behavior = _behavior;

    horizontal = 0;
    vertical = 0;
    angle = 0;
    magnitude = 0;

    hit_test = function(tx, ty) {
        if (is_circle) {
            return point_distance(tx, ty, cx, cy) <= size1;
        } else {
            return point_in_rectangle(tx, ty, cx - size1, cy - size2, cx + size1, cy + size2);
        }
    };

    claim = function(_tid, tx, ty) {
        if (tid != -1) { return false; }
        if (!hit_test(tx, ty)) { return false; }
        tid = _tid;
        on = true;
        if (behavior == touch_behavior.fixed) {
            origin_set = true;
        } else {
            ox = tx;
            oy = ty;
            origin_set = true;
        }
        return true;
    };

    track = function(tx, ty) {
        var _dx = tx - ox;
        var _dy = ty - oy;
        var _dist = point_distance(0, 0, _dx, _dy);

        if (_dist > 0) {
            angle = point_direction(0, 0, _dx, -_dy);
            var _clamped = min(_dist, radius);
            magnitude = _clamped / radius;
            var _ratio = _clamped / _dist;
            horizontal = (_dx * _ratio) / radius;
            vertical = (-_dy * _ratio) / radius;

            if (behavior == touch_behavior.adaptive) {
                if (_dist > radius) {
                    ox += _dx - (_dx * _ratio);
                    oy += _dy - (_dy * _ratio);
                }
            }
        } else {
            horizontal = 0;
            vertical = 0;
            angle = 0;
            magnitude = 0;
        }
    };

    release = function() {
        tid = -1;
        on = false;
        origin_set = false;
        if (behavior != touch_behavior.fixed) {
            ox = cx;
            oy = cy;
        }
        horizontal = 0;
        vertical = 0;
        angle = 0;
        magnitude = 0;
    };

    update = function() {
        if (tid == -1) { return; }
        if (device_mouse_check_button(tid, mb_left)) {
            var tx = device_mouse_x_to_gui(tid);
            var ty = device_mouse_y_to_gui(tid);
            track(tx, ty);
        } else {
            release();
        }
    };

    set_origin = function(_x, _y) {
        ox = _x;
        oy = _y;
    };
  
  set_radius = function(_r) {
    radius = _r;
  };
  
}


// ── btn ───────────────────────────────────────────────────────────────────────
function btn() constructor {
    previous = false;
    current  = false;
    pressed  = false;
    released = false;
    held     = 0;

    update = function(value) {
        previous = current;
        current  = value;
        pressed  = (!previous &&  current);
        released = ( previous && !current);
        held     = current ? held + 1 : 0;
    };
}


// ── axs ───────────────────────────────────────────────────────────────────────
function axs(_dz = 0.1) constructor {
    dz       = _dz;
    previous = 0;
    current  = 0;
    change   = 0;
    pressed  = false;
    released = false;

    update = function(value) {
        previous = current;
        current  = value;
        change   = current - previous;
        pressed  = (abs(previous) < dz && abs(current) >= dz);
        released = (abs(previous) >= dz && abs(current) < dz);
    };
}


// ── stck ──────────────────────────────────────────────────────────────────────
function stck(_dz = 0.1) constructor {
    dz         = _dz;
    horizontal = new axs(_dz);
    vertical   = new axs(_dz);

    dir  = { previous: 0, current: 0, change: 0 };
    tilt = { previous: 0, current: 0, change: 0 };

    update = function(hvalue, vvalue) {
        dir.previous  = dir.current;
        tilt.previous = tilt.current;

        var t = point_distance(0, 0, hvalue, vvalue);
        if (t > 1) { hvalue /= t; vvalue /= t; t = 1; }
        if (t > dz) {
            horizontal.update(hvalue);
            vertical.update(vvalue);
        } else {
            horizontal.update(0);
            vertical.update(0);
        }

        tilt.current = point_distance(0, 0, horizontal.current, vertical.current);
        dir.current  = point_direction(0, 0, horizontal.current, vertical.current);
        tilt.change  = tilt.current - tilt.previous;
        dir.change   = angle_difference(dir.current, dir.previous);
    };

    set_dz = function(value) {
        dz            = value;
        horizontal.dz = value;
        vertical.dz   = value;
    };
}


// ── Input ─────────────────────────────────────────────────────────────────────
enum input_modes { keyboard, gamepad, touch, search, delay }

function Input(mode = input_modes.delay) constructor {
    gp_id     = 0;
    self.mode = mode;

    // ── virtual gamepad state ─────────────────────────────────────────────
    joy_left  = new stck();  joy_right = new stck();

    south = new btn();  east = new btn();  west = new btn();  north = new btn();

    start  = new btn();  select = new btn();

    bumper_l  = new btn();  bumper_r  = new btn();
    trigger_l = new axs();  trigger_r = new axs();
    click_l   = new btn();  click_r   = new btn();

    up = new btn();  down = new btn();  left = new btn();  right = new btn();

    // ── invert flags ──────────────────────────────────────────────────────
    hl_invert = false;  vl_invert = false;
    hr_invert = false;  vr_invert = false;

    // ── keyboard bindings ─────────────────────────────────────────────────
    key = {
        a: ord("K"),  b: ord("L"),  x: ord("I"),  y: ord("O"),

        start:  vk_enter,
        select: vk_backspace,

        bumper_l:  ord("J"),  bumper_r:  ord("U"),
        trigger_l: ord("Y"),  trigger_r: ord("H"),
        click_l:   ord("M"),  click_r:   ord("N"),

        up: ord("Z"),  down: ord("X"),  left: ord("C"),  right: ord("V"),

        left_l:  ord("A"),  right_l: ord("D"),  up_l: ord("W"),  down_l: ord("S"),
        left_r:  ord("Q"),  right_r: ord("E"),  up_r: ord("R"),  down_r: ord("F"),
    };

    // ── gamepad bindings ──────────────────────────────────────────────────
    gp = {
        a: gp_face1,  b: gp_face2,  x: gp_face3,  y: gp_face4,

        start:  gp_start,
        select: gp_select,

        bumper_l:  gp_shoulderl,   bumper_r:  gp_shoulderr,
        trigger_l: gp_shoulderlb,  trigger_r: gp_shoulderrb,
        click_l:   gp_stickl,      click_r:   gp_stickr,

        up: gp_padu,  down: gp_padd,  left: gp_padl,  right: gp_padr,

        horizontal_l: gp_axislh,  vertical_l: gp_axislv,  hl_invert: false,  vl_invert: false,
        horizontal_r: gp_axisrh,  vertical_r: gp_axisrv,  hr_invert: true,   vr_invert: false,
    };

    // ── touch zones ───────────────────────────────────────────────────────
    touch = {
        max_points: 5,
        zones: {},
        priority: [],

        init: function() {
            var hw = SCREEN.half.width;
            var hh = SCREEN.half.height;
            var w  = SCREEN.width;
            var h  = SCREEN.height;

            zones.j = new touch_zone(hw / 2, hh, hw / 2, hh, touch_behavior.adaptive);
            zones.j.set_radius(60); 
            zones.b = new touch_zone(hw + (hw / 2), hh, hw / 2, hh, touch_behavior.adaptive);
            zones.p = new touch_zone(30, 30, 60);
            zones.d = new touch_zone(w - 30, 30, 60, undefined, touch_behavior.dynamic);
            zones.m = new touch_zone(w - 30, hh, 60);
            zones.c = new touch_zone(w - 30, h - 30, 60);
            zones.r = new touch_zone(hw, h - 30, hw / 4, 30, touch_behavior.dynamic);
            zones.r.set_radius(10); 

            priority = [zones.p, zones.d, zones.m, zones.c, zones.r, zones.j, zones.b];
        },

        update: function() {
            var _names = variable_struct_get_names(zones);
            var _len = array_length(_names);
            for (var i = 0; i < _len; i++) {
                zones[$ _names[i]].update();
            }

            for (var t = 0; t < max_points; t++) {
                if (!device_mouse_check_button(t, mb_left)) { continue; }

                var _claimed = false;
                for (var i = 0; i < _len; i++) {
                    if (zones[$ _names[i]].tid == t) { _claimed = true; break; }
                }
                if (_claimed) { continue; }

                var tx = device_mouse_x_to_gui(t);
                var ty = device_mouse_y_to_gui(t);
                var _plen = array_length(priority);
                for (var i = 0; i < _plen; i++) {
                    if (priority[i].claim(t, tx, ty)) { break; }
                }
            }
        },
    };
    touch.init();

    // ── update dispatch ───────────────────────────────────────────────────
    update = function() {
        switch (mode) {
            case input_modes.keyboard: _get_keyboard(); break;
            case input_modes.gamepad:  _get_gamepad();  break;
            case input_modes.touch:    _get_touch();    break;
            case input_modes.search:   _search();       break;
            case input_modes.delay:    _delay();        break;
        }
    };

    // ── keyboard ──────────────────────────────────────────────────────────
    _get_keyboard = function() {
        south.update(keyboard_check(key.a));
        east.update(keyboard_check(key.b));
        west.update(keyboard_check(key.x));
        north.update(keyboard_check(key.y));

        start.update(keyboard_check(key.start));
        select.update(keyboard_check(key.select));

        bumper_l.update(keyboard_check(key.bumper_l));
        bumper_r.update(keyboard_check(key.bumper_r));
        trigger_l.update(keyboard_check(key.trigger_l));
        trigger_r.update(keyboard_check(key.trigger_r));
        click_l.update(keyboard_check(key.click_l));
        click_r.update(keyboard_check(key.click_r));

        up.update(keyboard_check(key.up));
        down.update(keyboard_check(key.down));
        left.update(keyboard_check(key.left));
        right.update(keyboard_check(key.right));

        joy_left.update(
            keyboard_check(key.right_l) - keyboard_check(key.left_l),
            keyboard_check(key.up_l)    - keyboard_check(key.down_l)
        );
        joy_right.update(
            keyboard_check(key.right_r) - keyboard_check(key.left_r),
            keyboard_check(key.down_r)  - keyboard_check(key.up_r)
        );
    };

    // ── gamepad ───────────────────────────────────────────────────────────
    _get_gamepad = function() {
        south.update(gamepad_button_check(gp_id, gp.a));
        east.update(gamepad_button_check(gp_id, gp.b));
        west.update(gamepad_button_check(gp_id, gp.x));
        north.update(gamepad_button_check(gp_id, gp.y));

        start.update(gamepad_button_check(gp_id, gp.start));
        select.update(gamepad_button_check(gp_id, gp.select));

        bumper_l.update(gamepad_button_check(gp_id, gp.bumper_l));
        bumper_r.update(gamepad_button_check(gp_id, gp.bumper_r));
        trigger_l.update(gamepad_button_value(gp_id, gp.trigger_l));
        trigger_r.update(gamepad_button_value(gp_id, gp.trigger_r));
        click_l.update(gamepad_button_check(gp_id, gp.click_l));
        click_r.update(gamepad_button_check(gp_id, gp.click_r));

        up.update(gamepad_button_check(gp_id, gp.up));
        down.update(gamepad_button_check(gp_id, gp.down));
        left.update(gamepad_button_check(gp_id, gp.left));
        right.update(gamepad_button_check(gp_id, gp.right));

        joy_left.update(
            gamepad_axis_value(gp_id, gp.horizontal_l) * (gp.hl_invert ? -1 : 1),
            gamepad_axis_value(gp_id, gp.vertical_l)   * (gp.vl_invert ?  1 : -1)
        );
        joy_right.update(
            gamepad_axis_value(gp_id, gp.horizontal_r) * (gp.hr_invert ? -1 : 1),
            gamepad_axis_value(gp_id, gp.vertical_r)   * (gp.vr_invert ?  1 : -1)
        );
    };

    // ── touch ─────────────────────────────────────────────────────────────
    _get_touch = function() {
        touch.update();

        joy_left.update(touch.zones.j.horizontal, touch.zones.j.vertical);

        south.update(touch.zones.b.on);
        west.update(touch.zones.m.on);
        east.update(touch.zones.c.on);
        select.update(touch.zones.p.on);
        bumper_r.update(touch.zones.d.on);

        if (touch.zones.d.on) {
            joy_right.update(touch.zones.d.horizontal, touch.zones.d.vertical);
        } else {
            joy_right.update(touch.zones.r.horizontal, 0);
        }
    };

    // ── auto-detect ───────────────────────────────────────────────────────
    _search = function() {
        if (keyboard_check_released(vk_anykey)) {
            mode = input_modes.keyboard;
            _get_keyboard();
            return;
        }
        if (device_mouse_check_button_released(0, mb_any) /*&& PLATFORM.is_mobile()*/) {
            mode = input_modes.touch;
            return;
        }
        var _gp_num = gamepad_get_device_count();
        for (var _id = 0; _id < _gp_num; _id++) {
            if (gamepad_is_connected(_id)) {
                for (var _axc = 0; _axc < 4; _axc++) {
                    if (abs(gamepad_axis_value(_id, gp_axislh + _axc)) > 0.5) {
                        gp_id = _id;
                        mode  = input_modes.gamepad;
                        _get_gamepad();
                        return;
                    }
                }
                var _bt_num = gamepad_button_count(_id);
                for (var _bt = 0; _bt < _bt_num; _bt++) {
                    if (gamepad_button_check(_id, _bt)) {
                        gp_id = _id;
                        mode  = input_modes.gamepad;
                        _get_gamepad();
                        return;
                    }
                }
            }
        }
    };

    // ── startup delay ─────────────────────────────────────────────────────
    _delay = function() {
        static timer = 0;
        static limit = 30;
        timer++;
        if (timer > limit) { timer = 0; mode = input_modes.search; }
    };

    mode_set_search = function() { mode = input_modes.delay; };

    // ── toString ──────────────────────────────────────────────────────────
    toString = function() {
        switch (mode) {
            case input_modes.keyboard: return "keyboard";
            case input_modes.gamepad:  return "gamepad";
            case input_modes.touch:    return "touch";
            case input_modes.search:   return "search";
            case input_modes.delay:    return "delay";
            default:                   return "ERROR";
        }
    };
}