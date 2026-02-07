draw_clear(c_cornflowerblue)
var camera=camera_get_active();
camera_set_view_mat(camera,matrix_build_lookat(x,y+128,-128,x,y,z,0,0,1));
camera_set_proj_mat(camera,matrix_build_projection_perspective_fov(45,window_get_width()/window_get_height(),1,32000));
camera_apply(camera);