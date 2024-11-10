#include "mouse.h"
#include "window.h"

int main() {
  initialize_window_manager();

  while (1) {
    CGPoint point = get_mouse_position();
    focus_window_at_point(point);
    usleep(10000);
  }
}