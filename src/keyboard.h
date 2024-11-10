#ifndef KEYBOARD_H
#define KEYBOARD_H

typedef void (*KeyEventCallback)(int, int, int);

void set_key_event_callback(KeyEventCallback callback);
void start_key_listener();

#endif
