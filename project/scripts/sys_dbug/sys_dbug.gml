function Dbug() constructor {

    // ── system ────────────────────────────────────────────────────────────
    system = {
	    platform  : PLATFORM.toString(),
	    c_platform: c_white,
	    input     : INPUT.toString(),      // restored
	    _x        : SCREEN.topleft.x + 1,
	    _y        : SCREEN.topleft.y + 1,

	    update: function() {
	        self.input = INPUT.toString();  // restored
	    },

	    draw: function() {
	        draw_set_talign(fa_left, fa_top);
	        draw_text_outline(self._x, self._y, self.platform + " | " + self.input, self.c_platform); // restored
	    }
	};


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
        output    : "\n",
        index     : 0,
        index_max : 1,
        lines     : [],

        init: function() {
            draw_set_font(fnt_dbug);
            var t_height = max(1, string_height("Mouse"));
            var s_height = SCREEN.height;
            self.index_max = max(1, floor(s_height / t_height) - 2);
            self.index     = 0;
            self.lines     = array_create(self.index_max, undefined);
            self.output    = "\n";
        },

        add: function(label = null, data = null) {
            if (label == null) { return; }
            if (self.index > self.index_max) { return; }
            if (self.index == self.index_max) {
                self.lines[self.index - 1] += " - EOL -";
                self.index++;
                return;
            }
            var _s = string(label);
            if (data != null) { _s += " | " + string(data); }
            self.lines[self.index] = _s;
            self.index++;
        },

        add_coord: function(label = null, x = null, y = null, z = null, w = null) {
            var n = 0, s = "(";
            if (x != null) { s += string(x);                        n++; }
            if (y != null) { s += (n > 0 ? ", " : "") + string(y); n++; }
            if (z != null) { s += (n > 0 ? ", " : "") + string(z); n++; }
            if (w != null) { s += (n > 0 ? ", " : "") + string(w); n++; }
            s += ")";
            self.add(label, (n > 0) ? s : null);
        },

        update: function() {
            var len = array_length(self.lines);
            if (len <= 0) { self.output = "\n"; self.index = 0; return; }

            var end_index = clamp(self.index - 1, 0, len - 1);
            var out = "\n";
            for (var i = 0; i <= end_index; i++) {
                var v = self.lines[i];
                if (is_undefined(v)) { v = ""; }
                out += (i == 0) ? string(v) : ("\n" + string(v));
            }
            self.output = out;

            self.lines = array_create(self.index_max, undefined);
            self.index = 0;
        },

        draw: function() {
            if (self.on) {
                draw_set_talign(fa_left, fa_top);
                draw_text_outline(SCREEN.topleft.x + 1, SCREEN.topleft.y + 1, self.output);
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
    // TODO: restore when INPUT is implemented
    // input = { ... };


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
        // input.draw();  // TODO: restore when INPUT is implemented
    };
}