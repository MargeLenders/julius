#ifndef PLATFORM_IOS_H
#define PLATFORM_IOS_H

#include "SDL_platform.h"

#ifdef __IPHONEOS__

const char *ios_show_c3_path_dialog(int again);
void c3_path_chosen(char *new_path);
const char *ios_get_base_path(void);
struct SDL_Window;
void ios_attach_window_to_scene(struct SDL_Window *window);

#endif // __IPHONEOS__
#endif // PLATFORM_IOS_H
