#include <ApplicationServices/ApplicationServices.h>
#include <stdio.h>

typedef void (*KeyEventCallback)(int, int, int);

KeyEventCallback host_callback = NULL;

CGEventRef event_callback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
  if (type == kCGEventKeyDown || type == kCGEventKeyUp)
  {
    CGKeyCode keycode = (CGKeyCode)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
    int is_key_down = (type == kCGEventKeyDown) ? 1 : 0;
    int modifiers = (int)CGEventGetFlags(event);

    // Call the Go callback function
    if (host_callback != NULL)
    {
      host_callback(is_key_down, keycode, modifiers);
    }
  }
  return event;
}

void set_key_event_callback(KeyEventCallback callback)
{
  host_callback = callback;
}

void start_key_listener()
{
  CFMachPortRef event_tap = CGEventTapCreate(
      kCGSessionEventTap,
      kCGHeadInsertEventTap,
      0,
      CGEventMaskBit(kCGEventKeyDown) | CGEventMaskBit(kCGEventKeyUp),
      event_callback,
      NULL);

  if (!event_tap)
  {
    fprintf(stderr, "Failed to create event tap\n");
    exit(1);
  }

  CFRunLoopSourceRef run_loop_source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, event_tap, 0);
  CFRunLoopAddSource(CFRunLoopGetCurrent(), run_loop_source, kCFRunLoopCommonModes);
  CGEventTapEnable(event_tap, true);
  CFRunLoopRun();
}
