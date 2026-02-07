var _hspd=keyboard_check(ord("D"))-keyboard_check(ord("A"));
var _vspd=keyboard_check(ord("S"))-keyboard_check(ord("W"));

if (_hspd!=0){
	if (place_meeting(x + _hspd, y, obj_wall)) {
	    while (!place_meeting(x + sign(_hspd), y, obj_wall)) {
	        x += sign(_hspd);
	    }
	    _hspd = 0;
	}
}
if (_vspd!=0){
	if (place_meeting(x, y + _vspd, obj_wall)) {
	    while (!place_meeting(x, y + sign(_vspd), obj_wall)) {
	        y += sign(_vspd);
	    }
	    _vspd = 0;
	}
}
//Apply
x+=_hspd;
y+=_vspd;