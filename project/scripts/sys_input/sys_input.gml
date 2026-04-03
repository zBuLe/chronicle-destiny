enum input_modes { keyboard, gamepad, touch, search, delay }

function Input(mode = input_modes.delay) constructor {
    gp_id     = 0;
    self.mode = mode;

    // ── virtual gamepad state ─────────────────────────────────────────────
    joy_left  = new stck();  joy_right = new stck();

    a = new btn();  b = new btn();  x = new btn();  y = new btn();

    start = new btn();  select = new btn();

    bumper_l  = new btn();  bumper_r  = new btn();
    trigger_l = new axs();  trigger_r = new axs();
    click_l   = new btn();  click_r   = new btn();

    up = new btn();  down = new btn();  left = new btn();  right = new btn();

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
    }

    // ── gamepad bindings ──────────────────────────────────────────────────
    gp = {
        a: gp_face1,  b: gp_face2,  x: gp_face3,  y: gp_face4,

        start:  gp_start,
        select: gp_select,

        bumper_l:  gp_shoulderl,   bumper_r:  gp_shoulderr,
        trigger_l: gp_shoulderlb,  trigger_r: gp_shoulderrb,
        click_l:   gp_stickl,      click_r:   gp_stickr,

        up: gp_padu,  down: gp_padd,  left: gp_padl,  right: gp_padr,

        horizontal_l: gp_axislh,  vertical_l: gp_axislv, hl_invert: false, vl_invert: false,
        horizontal_r: gp_axisrh,  vertical_r: gp_axisrv, hr_invert: true, vr_invert: false,
    }

    // ── update dispatch ───────────────────────────────────────────────────
    update = function() {
        switch (mode) {
            case input_modes.keyboard: _get_keyboard(); break;
            case input_modes.gamepad:  _get_gamepad();  break;
            case input_modes.touch:    _get_touch();    break;
            case input_modes.search:   _search();       break;
            case input_modes.delay:    _delay();        break;
        }
    }

    // ── keyboard ──────────────────────────────────────────────────────────
    _get_keyboard = function() {
        a.update(keyboard_check(key.a));
        b.update(keyboard_check(key.b));
        x.update(keyboard_check(key.x));
        y.update(keyboard_check(key.y));

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
            keyboard_check(key.up_l)  - keyboard_check(key.down_l)
        );
        joy_right.update(
            keyboard_check(key.right_r) - keyboard_check(key.left_r),
            keyboard_check(key.down_r)  - keyboard_check(key.up_r)
        );
    }

    // ── gamepad ───────────────────────────────────────────────────────────
    _get_gamepad = function() {
        a.update(gamepad_button_check(gp_id, gp.a));
        b.update(gamepad_button_check(gp_id, gp.b));
        x.update(gamepad_button_check(gp_id, gp.x));
        y.update(gamepad_button_check(gp_id, gp.y));

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
            gamepad_axis_value(gp_id, gp.horizontal_l) * (gp.hl_invert?-1:1),
            gamepad_axis_value(gp_id, gp.vertical_l) * (gp.vl_invert?1:-1)
        );
        joy_right.update(
            gamepad_axis_value(gp_id, gp.horizontal_r) * (gp.hr_invert?-1:1),
            gamepad_axis_value(gp_id, gp.vertical_r) * (gp.vr_invert?1:-1)
        );
    }

    // ── touch (stub — to be implemented when mobile testing begins) ───────
    _get_touch = function() {
        // TODO: implement touch input
    }

    // ── auto-detect ───────────────────────────────────────────────────────
    _search = function() {
        if (keyboard_check_released(vk_anykey)) {
            mode = input_modes.keyboard; return;
        }
        if (device_mouse_check_button_released(0, mb_any) && PLATFORM.is_mobile()) {
            mode = input_modes.touch; return;
        }
        var _gp_num = gamepad_get_device_count();
        for (var _id = 0; _id < _gp_num; _id++) {
            if (gamepad_is_connected(_id)) {
                var _bt_num = gamepad_button_count(_id);
                for (var _bt = 0; _bt < _bt_num; _bt++) {
                    if (gamepad_button_check(_id, _bt)) {
                        gp_id = _id;
                        mode  = input_modes.gamepad;
                        return;
                    }
                }
            }
        }
    }

    // ── startup delay ─────────────────────────────────────────────────────
    _delay = function() {
        static timer = 0;
        static limit = 30;
        timer++;
        if (timer > limit) { timer = 0; mode = input_modes.search; }
    }
	
	mode_set_search = function() { mode = input_modes.delay; }


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
    }
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
  }
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
  }
}


// ── stck ──────────────────────────────────────────────────────────────────────
function stck(_dz = 0.1) constructor {
  dz         = _dz;
  horizontal = new axs(_dz);
  vertical   = new axs(_dz);

  dir = { previous: 0, current: 0, change: 0 };
  tilt = { previous: 0, current: 0, change: 0 };

  update = function(hvalue, vvalue) {
    dir.previous  = dir.current;
    tilt.previous = tilt.current;

    var t = point_distance(0, 0, hvalue, vvalue);
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
  }

  set_dz = function(value) {
    dz             = value;
    horizontal.dz  = value;
    vertical.dz    = value;
  }
}