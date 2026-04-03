enum platform_type { error, desktop, mobile, web }

function Platform() constructor {
  type     = platform_type.error;
  compiled = code_is_compiled();

  toString = function() {
    switch (type) {
      case platform_type.desktop: return "Desktop";
      case platform_type.mobile:  return "Mobile";
      case platform_type.web:     return "Web";
      default:                    return "ERROR";
    }
  }

  is_desktop = function() { return type == platform_type.desktop; }
  is_mobile  = function() { return type == platform_type.mobile;  }
  is_web     = function() { return type == platform_type.web;     }

  init = function() {
    if (os_browser == browser_not_a_browser) {
      switch (os_type) {
        case os_windows:
        case os_linux:
        case os_macosx:
          type = platform_type.desktop; break;
        case os_android:
        case os_ios:
          type = platform_type.mobile; break;
        default:
          type = platform_type.error; break;
      }
    } else {
      type = platform_type.web;
    }
  }

  init();
}
