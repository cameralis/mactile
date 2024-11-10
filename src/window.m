#import <AppKit/AppKit.h>
#import <ApplicationServices/ApplicationServices.h>

#define MAX_DEPTH 10

AXUIElementRef _application = NULL;

AXUIElementRef get_window_from_element(AXUIElementRef element, int depth) {
  AXUIElementRef window = NULL;

  if (element) {
    if (depth >= MAX_DEPTH) {
      NSLog(@"Max window depth reached");
      CFRelease(element);
    } else {
      CFStringRef element_role = NULL;
      AXUIElementCopyAttributeValue(element, kAXRoleAttribute,
                                    (CFTypeRef *)&element_role);
      bool element_role_invalid = !element_role;
      if (element_role) {
        if (CFEqual(element_role, kAXDockItemRole) ||
            CFEqual(element_role, kAXMenuItemRole) ||
            CFEqual(element_role, kAXMenuRole) ||
            CFEqual(element_role, kAXMenuBarRole) ||
            CFEqual(element_role, kAXMenuBarItemRole)) {
          CFRelease(element_role);
          CFRelease(element);
        } else if (CFEqual(element_role, kAXWindowRole) ||
                   CFEqual(element_role, kAXSheetRole) ||
                   CFEqual(element_role, kAXDrawerRole)) {
          CFRelease(element_role);
          window = element;
        } else {
          CFRelease(element_role);
          element_role_invalid = true;
        }
      }
      if (element_role_invalid) {
        AXUIElementCopyAttributeValue(element, kAXParentAttribute,
                                      (CFTypeRef *)&window);
        bool no_parent = !window;
        window = get_window_from_element(window, ++depth);
        CFRelease(element);
      }
    }
  }

  return window;
}

AXUIElementRef get_window_at_point(CGPoint point) {
  AXUIElementRef element = NULL;
  AXError error = AXUIElementCopyElementAtPosition(_application, point.x,
                                                   point.y, &element);

  AXUIElementRef window = NULL;
  if (element) {
    window = get_window_from_element(element, 0);
  } else if (error == kAXErrorCannotComplete ||
             error == kAXErrorNotImplemented) {
    // fallback, happens for apps that do not support the Accessibility API
    NSLog(@"Copy element: no accessibility support");
  } else if (error == kAXErrorAttributeUnsupported) {
    // no fallback, happens when hovering into volume/wifi menubar window
    NSLog(@"Copy element: attribute unsupported");
  } else if (error == kAXErrorFailure) {
    // no fallback, happens when hovering over the menubar itself
    NSLog(@"Copy element: failure");
  } else if (error == kAXErrorIllegalArgument) {
    // no fallback, happens in (Open, Save) dialogs
    NSLog(@"Copy element: illegal argument");
  } else {
    NSLog(@"Copy element: AXError %d", error);
  }
  return window;
}

void activate_window(pid_t pid) {
  NSRunningApplication *app =
      [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
  if (app) {
    [app activateWithOptions:NSApplicationActivateIgnoringOtherApps];
  } else {
    printf("Unable to find running application for PID: %d\n", pid);
  }
}

bool raise_window(AXUIElementRef window) {
  AXError result = AXUIElementPerformAction(window, kAXRaiseAction);
  return result == kAXErrorSuccess;
}

void focus_window(AXUIElementRef window) {
  if (!raise_window(window)) {
    printf("Unable to raise window\n");
    return;
  }
  pid_t pid;
  if (AXUIElementGetPid(window, &pid) == kAXErrorSuccess) {
    activate_window(pid);
  } else {
    printf("Unable to get PID for window\n");
  }
}

void focus_window_at_point(CGPoint point) {
  AXUIElementRef window = get_window_at_point(point);
  if (!window) {
    printf("Unable to find window at point\n");
    return;
  }
  CFStringRef title = NULL;
  AXUIElementCopyAttributeValue(window, kAXTitleAttribute, (CFTypeRef *)&title);
  if (title) {
    NSLog(@"Active window: %@", title);
    CFRelease(title);
  }
  focus_window(window);
  CFRelease(window);
}

void initialize_window_manager() {
  _application = AXUIElementCreateSystemWide();
  NSDictionary *options =
      @{(id)CFBridgingRelease(kAXTrustedCheckOptionPrompt) : @YES};
  bool trusted =
      AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options);
  NSLog(@"AXIsProcessTrusted: %s", trusted ? "YES" : "NO");
}
