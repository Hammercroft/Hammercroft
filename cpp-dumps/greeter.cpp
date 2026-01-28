#include <X11/X.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Compile with g++ greeter.cpp -L/usr/X11R6/lib -lX11 -o greeter

int main(){
    Display *display;
    Window window;
    XEvent event;
    int screen;

    // 1. Open connection to X Server
    display = XOpenDisplay(NULL);
    if (display == NULL) {
        fprintf(stderr, "Cannot open display\n");
        exit(1);
    }
    screen = DefaultScreen(display);

    // 2. Window Dimensions
    int width = 650;
    int height = 300;

    // Get screen size so as to center the window
    int scrW = DisplayWidth(display, screen);
    int scrH = DisplayHeight(display, screen);
    int x = (scrW - width) / 2;
    int y = (scrH - height) / 2;

    // 3. Create the window
    window = XCreateSimpleWindow(display,
                                 RootWindow(display, screen),
                                 x,
                                 y,
                                 width,
                                 height,
                                 1,
                                 BlackPixel(display, screen),
                                 WhitePixel(display, screen)
                                 );

    // 4. Window properties
    XStoreName(display,window,"Welcome to the lightweight session!");

    XSelectInput(display, window, ExposureMask | KeyPressMask | ButtonPressMask);

    // Remove decorators
    XSetWindowAttributes windowAttributes;
    windowAttributes.override_redirect = True;
    XChangeWindowAttributes(display, window, CWOverrideRedirect, &windowAttributes);

    // 5. Show the window
    XMapWindow(display, window);

    // 6. Event Loop
    while (1) {
        XNextEvent(display, &event);

        // Draw the content
        // Draw the content
        if (event.type == Expose) {
            // Arrays of text to print
            const char* lines[] = {
                "Welcome to the lightweight session!",
                "This session is made to stretch out available system memory for applications.",
                "The environment lacks the desktop, bluetooth functionality,",
                "keyboard shortcuts, and a Wayland compositor.", // Split for width
                "",
                "If you need any of those, please log out and select",
                "Plasma (Wayland) as the session type.",
                "",
                "Click anywhere on this window to close it."
            };

            int y_pos = 50; // Start vertical position
            int line_height = 20; // Space between lines

            // Loop through lines and draw them
            for (int i = 0; i < 9; i++) {
                XDrawString(display, window, DefaultGC(display, screen),
                            20, y_pos, lines[i], strlen(lines[i]));
                y_pos += line_height;
            }
        }

        // Close on click or keypress
        if (event.type == ButtonPress || event.type == KeyPress)
            break;
    }

    // 7. Cleanup
    XCloseDisplay(display);
    return 0;
}
