#include <ApplicationServices/ApplicationServices.h>

CGPoint get_mouse_position() {
  CGEventRef _event = CGEventCreate(NULL);
  CGPoint location = CGEventGetLocation(_event);
  CFRelease(_event);
  return location;
}