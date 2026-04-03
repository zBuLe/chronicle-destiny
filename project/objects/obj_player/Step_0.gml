INPUT.update();

// camera rotation — right stick horizontal
CAMERA.rotate_orbit(INPUT.joy_right.horizontal.current * 2);
CAMERA.update();

// camera-relative axes
var _forward = CAMERA.get_forward();
var _right   = CAMERA.get_right();

// movement from left stick
var _raw_h = INPUT.joy_left.horizontal.current;
var _raw_v = INPUT.joy_left.vertical.current;

// project onto camera axes
var _hspd = _raw_h * _right.x + _raw_v * _forward.x;
var _vspd = _raw_h * _right.y + _raw_v * _forward.y;

// normalize diagonal
var _len = point_distance(0, 0, _hspd, _vspd);
if (_len > 0) {
    _hspd = (_hspd / _len) * move_spd;
    _vspd = (_vspd / _len) * move_spd;
}

// collision X
if (_hspd != 0) {
    if (place_meeting(x + _hspd, y, obj_wall)) {
        while (!place_meeting(x + sign(_hspd), y, obj_wall)) {
            x += sign(_hspd);
        }
        _hspd = 0;
    }
}

// collision Y
if (_vspd != 0) {
    if (place_meeting(x, y + _vspd, obj_wall)) {
        while (!place_meeting(x, y + sign(_vspd), obj_wall)) {
            y += sign(_vspd);
        }
        _vspd = 0;
    }
}

// apply
x += _hspd;
y += _vspd;