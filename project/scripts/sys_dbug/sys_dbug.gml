function Dbug() constructor {

    // ── system ────────────────────────────────────────────────────────────
    system = {
	    platform  : PLATFORM.toString(),
	    c_platform: c_error,
      c_compiled: PLATFORM.compiled?c_black:c_gray,
	    input     : INPUT.toString(),
	    x        : SCREEN.topleft.x + 1,
	    y        : SCREEN.topleft.y + 1,
      
      init: function(){
        switch (PLATFORM.type){
          case platform_type.desktop: c_platform = c_blue; break;
          case platform_type.mobile: c_platform = c_orange; break;
          case platform_type.web: c_platform = c_yellow; break;
          case platform_type.error: c_platform = c_error; break;
        }
      },
      

	    update: function() {
	        input = INPUT.toString();
	    },

	    draw: function() {
	        draw_set_talign(fa_left, fa_top);
	        draw_text_outline(x, y, platform + " | " + input, c_platform,c_compiled);
	    },
      
      
	};
  system.init();

    // ── level ─────────────────────────────────────────────────────────────
    level = {
        draw: function() {
            draw_set_talign(fa_center, fa_top);
            draw_text_outline(SCREEN.top.x, SCREEN.top.y, room_get_name(room) + " (" + string(instance_count) + ")");
        }
    };


    // ── screen ────────────────────────────────────────────────────────────
    screen = {
        draw: function() {
            draw_set_talign(fa_right, fa_top);
            var c_fps = fps_real >= game_get_speed(gamespeed_fps) ? c_green : c_red;
            var l1 = string(fps_real) + ":" + string(fps);
            var l2 = "\n(" + string(SCREEN.width) + "X" + string(SCREEN.height) + ")x" + string(SCREEN.scale);
            draw_text_outline(SCREEN.topright.x, SCREEN.topright.y, l1, c_fps);
            draw_text_outline(SCREEN.topright.x, SCREEN.topright.y, l2);
        }
    };


    // ── trace ─────────────────────────────────────────────────────────────
trace = {
    on        : true,
    index     : 0,
    index_max : 1,
    lines     : [],

    init: function() {
        draw_set_font(fnt_dbug);
        var t_height = max(1, string_height("M"));
        self.index_max = max(1, floor(SCREEN.height / t_height) - 2);
        self.index = 0;
        self.lines = array_create(self.index_max, undefined);
    },

    add: function(label = null, data = null, c_text = c_white, c_out = c_black) {
        if (label == null) { return; }
        if (self.index > self.index_max) { return; }
        if (self.index == self.index_max) {
            self.lines[self.index - 1].text += " - EOL -";
            self.index++;
            return;
        }
        var _s = string(label);
        if (data != null) { _s += " | " + string(data); }
        self.lines[self.index] = { text: _s, c_text: c_text, c_out: c_out };
        self.index++;
    },

    add_coord: function(label = null, x = null, y = null, z = null, w = null, c_text = c_white, c_out = c_black) {
        var n = 0, s = "(";
        if (x != null) { s += string(x);                        n++; }
        if (y != null) { s += (n > 0 ? ", " : "") + string(y); n++; }
        if (z != null) { s += (n > 0 ? ", " : "") + string(z); n++; }
        if (w != null) { s += (n > 0 ? ", " : "") + string(w); n++; }
        s += ")";
        self.add(label, (n > 0) ? s : null, c_text, c_out);
    },

    /// @function         add_sep(label, len, fixed, char, c_text, c_out)
    /// @description      Adds a separator line to the trace log.
    /// @param {String}   label   Text before the separator characters. Default: ""
    /// @param {Real}     len     Number of separator characters (or total width if fixed). Default: 9
    /// @param {Bool}     fixed   If true, len is the total width including label. Default: false
    /// @param {String}   char    Character to repeat as separator. Default: "-"
    /// @param {Constant} c_text  Text color. Default: c_white
    /// @param {Constant} c_out   Outline color. Default: c_black
    add_sep: function(label = "", len = 9, fixed = false, char = "-", c_text = c_white, c_out = c_black) {
        var _pad = fixed ? max(0, len - string_length(label)) : len;
        var _sep = "";
        repeat (_pad) { _sep += char; }
        self.add(label + _sep, null, c_text, c_out);
    },

    update: function() {
        self.lines = array_create(self.index_max, undefined);
        self.index = 0;
    },

    draw: function() {
        if (self.on) {
            draw_set_font(fnt_dbug);
            draw_set_talign(fa_left, fa_top);
            var _x = SCREEN.topleft.x + 1;
            var _h = max(1, string_height("M"));
            var _y = SCREEN.topleft.y + 1 + _h;
            var end_index = clamp(self.index - 1, 0, array_length(self.lines) - 1);
            for (var i = 0; i <= end_index; i++) {
                var _line = self.lines[i];
                if (is_undefined(_line)) continue;
                draw_text_outline(_x, _y + (i * _h), _line.text, _line.c_text, _line.c_out);
            }
        }
    }
};
trace.init();


    // ── build ─────────────────────────────────────────────────────────────
    build = {
        draw: function() {
            draw_set_talign(fa_left, fa_bottom);
            draw_text_outline(SCREEN.bottomleft.x + 1, SCREEN.bottomleft.y - 1, VERSION);
        }
    };


    // ── input (virtual gamepad overlay) ───────────────────────────────────
input_vgp = {
    style: 0,  // 0 = Xbox layout (stick left, dpad low-right), 1 = PS layout (dpad left, stick low-right)
    _p: array_create(18 * 2, 0),

    init: function() {
        var _size_w = 80, _size_h = 50;
        var _x = SCREEN.bottomright.x, _y = SCREEN.bottomright.y;
        var cx = _x - (_size_w / 2), cy = _y - (_size_h / 2);
        var nr_o = 10, fr_o = 25, bt_o = 8, rr_o = 15, sh_o = 25, sh_t = 34, sh_b = 40, pd_o = 6;
        var bt_x = cx + fr_o, bt_y = cy;
        var sh_x = cx, sh_y = cy - sh_o;
        var rs_x = cx + nr_o, rs_y = cy + rr_o;

        if (style == 0) { var pd_x = cx - nr_o; var pd_y = cy + rr_o; var ls_x = cx - fr_o; var ls_y = cy; }
        else             { var pd_x = cx - fr_o; var pd_y = cy;        var ls_x = cx - nr_o; var ls_y = cy + rr_o; }

        // 0: area (4 values)
        _p[0]  = _x - _size_w; _p[1]  = _y - _size_h; _p[2]  = _x; _p[3]  = _y;
        // 1: start,  2: select
        _p[4]  = cx + 5;  _p[5]  = cy;
        _p[6]  = cx - 5;  _p[7]  = cy;
        // 3: south,  4: east,  5: west,  6: north
        _p[8]  = bt_x;        _p[9]  = bt_y + bt_o;
        _p[10] = bt_x + bt_o; _p[11] = bt_y;
        _p[12] = bt_x - bt_o; _p[13] = bt_y;
        _p[14] = bt_x;        _p[15] = bt_y - bt_o;
        // 7–10: dpad
        _p[16] = pd_x;        _p[17] = pd_y - pd_o;
        _p[18] = pd_x;        _p[19] = pd_y + pd_o;
        _p[20] = pd_x - pd_o; _p[21] = pd_y;
        _p[22] = pd_x + pd_o; _p[23] = pd_y;
        // 11–12: bumpers
        _p[24] = sh_x - sh_b; _p[25] = sh_y;
        _p[26] = sh_x + sh_b; _p[27] = sh_y;
        // 13–14: triggers
        _p[28] = sh_x - sh_t; _p[29] = sh_y;
        _p[30] = sh_x + sh_t; _p[31] = sh_y;
        // 15–16: sticks
        _p[32] = ls_x; _p[33] = ls_y;
        _p[34] = rs_x; _p[35] = rs_y;
    },

    _draw_btn: function(xx, yy, _btn, img) {
        var sc = 1, cc = c_white;
        if (_btn.pressed)       { sc = 1.5; cc = c_black; }
        else if (_btn.released) { sc = 1.5; }
        draw_sprite_ext(spr_vgp_dbug, img + _btn.current, xx, yy, sc, sc, 0, cc, 1);
    },

    _draw_axs: function(xx, yy, _axs, img) {
        var sc = 1, cc = c_white;
        if (_axs.pressed)       { sc = 1.5; cc = c_black; }
        else if (_axs.released) { sc = 1.5; }
        draw_sprite_ext(spr_vgp_dbug, img, xx, yy, sc, sc, 0, cc, 1);
        draw_sprite_ext(spr_vgp_dbug, img + 1, xx, yy, _axs.current, 1, 0, cc, 1);
    },

    _draw_joystick: function(xx, yy, img, joy, click) {
        _draw_btn(xx, yy, click, img - 2);
        var v = 6;
        xx += joy.horizontal.current * v;
        yy -= joy.vertical.current * v;
        draw_sprite(spr_vgp_dbug, img + click.current, xx, yy);
    },
    
    _draw_invert: function(xx, yy, h_inv, v_inv, img) {
      if (h_inv) { draw_sprite(spr_vgp_dbug, img, xx, yy); }
      if (v_inv) { draw_sprite(spr_vgp_dbug, img + 1, xx, yy); }
    },

    draw: function() {
        // background
        draw_set_color(c_navy);
        draw_rectangle(_p[0], _p[1], _p[2], _p[3], false);
        draw_set_color(c_white);

        _draw_btn(_p[4],  _p[5],  INPUT.start,  8);
        _draw_btn(_p[6],  _p[7],  INPUT.select, 10);

        _draw_btn(_p[8],  _p[9],  INPUT.south, 0);
        _draw_btn(_p[10], _p[11], INPUT.east,  2);
        _draw_btn(_p[12], _p[13], INPUT.west,  4);
        _draw_btn(_p[14], _p[15], INPUT.north, 6);

        _draw_btn(_p[16], _p[17], INPUT.up,    12);
        _draw_btn(_p[18], _p[19], INPUT.down,  14);
        _draw_btn(_p[20], _p[21], INPUT.left,  16);
        _draw_btn(_p[22], _p[23], INPUT.right, 18);

        _draw_btn(_p[24], _p[25], INPUT.bumper_l, 20);
        _draw_btn(_p[26], _p[27], INPUT.bumper_r, 22);
        _draw_axs(_p[28], _p[29], INPUT.trigger_l, 24);
        _draw_axs(_p[30], _p[31], INPUT.trigger_r, 26);

        _draw_joystick(_p[32], _p[33], 30, INPUT.joy_left,  INPUT.click_l);
        _draw_joystick(_p[34], _p[35], 30, INPUT.joy_right, INPUT.click_r);
      
        _draw_invert(_p[32], _p[33], INPUT.hl_invert, INPUT.vl_invert, 32);
        _draw_invert(_p[34], _p[35], INPUT.hr_invert, INPUT.vr_invert, 32);

        draw_set_talign(fa_center, fa_top);
        draw_text((_p[0] + _p[2]) / 2, _p[29], INPUT.gp_id);
    }
};
input_vgp.init();

touch_dbug = {
    draw: function() {
        if (INPUT.mode != input_modes.touch) { return; }
        var _z = INPUT.touch.zones;

        // helper to draw a zone
        var _draw_zone = function(zone, c) {
            draw_set_color(c);
            draw_set_alpha(zone.on ? 0.5 : 0.75);
            if (zone.is_circle) {
                draw_circle(zone.cx, zone.cy, zone.size1, false);
            } else {
                draw_rectangle(zone.cx - zone.size1, zone.cy - zone.size2,
                               zone.cx + zone.size1, zone.cy + zone.size2, false);
            }
        };

        _draw_zone(_z.b, c_white);
        _draw_zone(_z.d, c_yellow);
        _draw_zone(_z.p, c_green);
        _draw_zone(_z.m, c_orange);
        _draw_zone(_z.c, c_red);
        _draw_zone(_z.r, c_aqua);

        // joystick origin + thumb
        draw_set_color(c_blue);
        draw_set_alpha(0.25);
        if (_z.j.origin_set) {
            draw_circle(_z.j.ox, _z.j.oy, _z.j.radius, false);
            var _tx = _z.j.ox + (_z.j.horizontal * _z.j.radius);
            var _ty = _z.j.oy - (_z.j.vertical * _z.j.radius);
            draw_circle(_tx, _ty, 30, false);
        }

        draw_set_alpha(1);
    }
};  
  

    // ── top-level update / draw ───────────────────────────────────────────
    update = function() {
        system.update();
        trace.update();
    };

    draw = function() {
      draw_set_font(fnt_dbug);
      system.draw();
      level.draw();
      screen.draw();
      trace.draw();
      build.draw();
      input_vgp.draw();
      touch_dbug.draw();
    };
}