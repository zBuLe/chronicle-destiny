
// LEFT STICK
DBUG.trace.add("lH ",  INPUT.joy_left.horizontal.current);
DBUG.trace.add("lHr", gamepad_axis_value(0, gp_axislh));

DBUG.trace.add("lV ",  INPUT.joy_left.vertical.current, c_blue);
DBUG.trace.add("lVr", gamepad_axis_value(0, gp_axislv));

DBUG.trace.add("------------------");

// RIGHT STICK
DBUG.trace.add("rH ",  INPUT.joy_right.horizontal.current);
DBUG.trace.add("rHr", gamepad_axis_value(0, gp_axisrh));

DBUG.trace.add("rV ",  INPUT.joy_right.vertical.current);
DBUG.trace.add("rVr", gamepad_axis_value(0, gp_axisrv));
DBUG.trace.add_sep("try",,)
DBUG.trace.add_sep("try",5,)
DBUG.trace.add_sep("try",5,true)
DBUG.trace.add_sep("try",5,true,"/",c_cornflower,c_lime)
DBUG.trace.add_sep("trybernacle",5,true)
DBUG.trace.add("SNAP",CAMERA.snap);
DBUG.trace.add("------------------");
DBUG.trace.add(gp_axislh,gp_axislv);
DBUG.trace.add(gp_axisrh,gp_axisrv);

