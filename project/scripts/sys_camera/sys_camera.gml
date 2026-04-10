enum camera_mode {
  none,
  orbit,
  free
}
function Camera() constructor {
    mode  = camera_mode.none;
    focus = noone;

	from = { x: SCREEN.width / 2, y: SCREEN.height,     z: -SCREEN.height / 2 };
	to   = { x: SCREEN.width / 2, y: SCREEN.height / 2, z: 0 };
    up   = { x: 0,              y: 0,               z: 1 };

    target = {
        from: { x: SCREEN.width / 2, y:  SCREEN.height,     z: -SCREEN.height / 2 },
        to:   { x:  SCREEN.width / 2, y:  SCREEN.height / 2, z: 0 },
        up:   { x: 0,              y: 0,               z: 1 }
    };

    offset = {
        from: { x: 0, y: 128, z: -128 },
        to:   { x: 0, y: 0,   z: 0 },
        up:   { x: 0, y: 0,   z: 1 }
    };

    orbit = { dir: 45, dist: 256, ele: 35.264 };
    free  = { pitch: 0, yaw: 0, roll: 0 };
    snap  = false;

    // Ortho commented out — GML tile/3D issues
     pro_mat = matrix_build_projection_ortho(SCREEN.width / 2, SCREEN.height / 2, 1, 32000);

    update = function() {
        switch (mode) {
            case camera_mode.none:  update_none();  break;
            case camera_mode.orbit: update_orbit(); break;
            case camera_mode.free:  update_free();  break;
        }
        update_to_target();
    };

    update_none = function(update_from = true) {
        if (focus == noone) { return; }
        if (instance_exists(focus)) {
            target.to.x = focus.x + offset.to.x;
            target.to.y = focus.y + offset.to.y;
            target.to.z = focus.z + offset.to.z;
            if (update_from) {
                target.from.x = focus.x + offset.from.x;
                target.from.y = focus.y + offset.from.y;
                target.from.z = focus.z + offset.from.z;
            }
        } else {
            focus = noone;
        }
    };

    update_orbit = function() {
        if (focus == noone) { mode = camera_mode.none; return; }
        if (!instance_exists(focus)) { focus = noone; mode = camera_mode.none; return; }

        target.to.x = focus.x + offset.to.x;
        target.to.y = focus.y + offset.to.y;
        target.to.z = focus.z + offset.to.z;

        orbit.dir = rollover_angle(orbit.dir);
        orbit.ele = clamp(orbit.ele, -89.9, 89.9);

        var _dir = degtorad(orbit.dir);
        var _ele = degtorad(orbit.ele);
        var _r   = orbit.dist;

        var _offx = _r * cos(_ele) * cos(_dir);
        var _offy = _r * cos(_ele) * sin(_dir);
        var _offz = -_r * sin(_ele);

        target.from.x = target.to.x + _offx;
        target.from.y = target.to.y + _offy;
        target.from.z = target.to.z + _offz;
    };

    update_free = function() {
        if (focus == noone) { mode = camera_mode.none; return; }
        if (!instance_exists(focus)) { focus = noone; mode = camera_mode.none; return; }

        target.from.x = focus.x + offset.from.x;
        target.from.y = focus.y + offset.from.y;
        target.from.z = focus.z + offset.from.z;

        var _yaw   = degtorad(free.yaw);
        var _pitch = degtorad(free.pitch);

        var _fx = cos(_pitch) * cos(_yaw);
        var _fy = cos(_pitch) * sin(_yaw);
        var _fz = -sin(_pitch);

        target.to.x = target.from.x + _fx;
        target.to.y = target.from.y + _fy;
        target.to.z = target.from.z + _fz;
    };

    update_to_target = function(ease = 0.1) {
        ease = clamp(ease, 0, 1);

        from.x = lerp(from.x, target.from.x, ease);
        from.y = lerp(from.y, target.from.y, ease);
        from.z = lerp(from.z, target.from.z, ease);

        to.x = lerp(to.x, target.to.x, ease);
        to.y = lerp(to.y, target.to.y, ease);
        to.z = lerp(to.z, target.to.z, ease);
    };

    rotate_orbit = function(val) {
        static snap_sign = 0;

        orbit.dir += val;
        orbit.dir  = round(orbit.dir);
        orbit.dir  = rollover_angle(orbit.dir);

        if (snap) {
            if (abs(val) < 0.001) {
                if (orbit.dir mod 45 != 0) {
                    orbit.dir += (orbit.dir mod 45 > 22.5) ? 1 : -1;
                }
            }
        } else {
            if (abs(val) < 0.001) {
                if (orbit.dir mod 45 != 0) {
                    orbit.dir += snap_sign;
                }
            } else {
                snap_sign = sign(val);
            }
        }
    };

    get_forward = function() {
        var _dir = degtorad(orbit.dir);
        var _ele = degtorad(orbit.ele);
        return {
            x: -cos(_ele) * cos(_dir),
            y: -cos(_ele) * sin(_dir)
        };
    };

    get_right = function() {
        var _dir = degtorad(orbit.dir);
        return {
            x: sin(_dir),
            y:  -cos(_dir)
        };
    };

    draw = function() {
        draw_clear(c_cornflower);
        var _cam = camera_get_active();
        camera_set_view_mat(_cam, matrix_build_lookat(
            from.x, from.y, from.z,
            to.x,   to.y,   to.z,
            up.x,   up.y,   up.z
        ));
        // Perspective — swap back to pro_mat when ortho issues are resolved
		//camera_set_proj_mat(_cam, matrix_build_projection_perspective_fov(30,SCREEN.width / SCREEN.height,1, 32000));
      camera_set_proj_mat(_cam, pro_mat);
        camera_apply(_cam);
    };
}