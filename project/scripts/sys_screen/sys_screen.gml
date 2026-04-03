function Screen(w = 640, h = 360, s = 1) constructor {
  width      = w;
  height     = h;
  scale      = s;
  max_scale  = 1;
  fullscreen = false;

  set_anchors = function() {
    var w  = width;
    var h  = height;
    var hw = w / 2;
    var hh = h / 2;

    half    = { width: hw,    height: hh    };
    third   = { width: w / 3, height: h / 3 };
    quarter = { width: w / 4, height: h / 4 };
    fifth   = { width: w / 5, height: h / 5 };

    center      = { x: hw, y: hh };

    topleft     = { x: 0,  y: 0  };
    topright    = { x: w,  y: 0  };
    bottomleft  = { x: 0,  y: h  };
    bottomright = { x: w,  y: h  };

    top    = { x: hw, y: 0  };
    bottom = { x: hw, y: h  };
    left   = { x: 0,  y: hh };
    right  = { x: w,  y: hh };
  }

  init = function() {
    var _display_width  = display_get_width();
    var _display_height = display_get_height();

    aspect_ratio = _display_width / _display_height;

    if (!PLATFORM.is_web()) {
      // adjust height so display divides evenly into game height
      if (_display_height mod height != 0) {
        var _d = round(_display_height / height);
        height = _display_height / _d;
      }
      width = round(height * aspect_ratio);

      // force even dimensions (avoids sub-pixel rounding issues)
      if (width  & 1) { width++;  }
      if (height & 1) { height++; }

      max_scale = max(1, floor(_display_width / width)); // guard: never 0
      if (scale > max_scale) { scale = max_scale; }
    }

    // non-desktop platforms: no scaling
    if (!PLATFORM.is_desktop()) {
      scale     = 1;
      max_scale = 1;
    }
  }

  set_resolution = function() {
    surface_resize(application_surface, width, height);
    display_set_gui_size(width, height);
    window_set_size(width * scale, height * scale);
    window_set_fullscreen(false);
    set_anchors();
    if (PLATFORM.is_desktop()) { window_center(); }
  }

  init();
  set_resolution();
}
