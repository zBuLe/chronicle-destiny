if keyboard_check(KEY_DBUG){ 
  if keyboard_check_pressed(ord("1")){
  	INPUT.mode_set_search();
  }
  if keyboard_check_pressed(ord("2")){
  	CAMERA.snap=!CAMERA.snap;	
  }
  if (keyboard_check_released(vk_tab)) {
      if (!PLATFORM.is_web()) {
          SCREEN.scale++;
          if (SCREEN.scale > SCREEN.max_scale) { SCREEN.scale = 1; }
          SCREEN.set_resolution();
      }
  }
}
CAMERA.update();
DBUG.update();
FADE.update();