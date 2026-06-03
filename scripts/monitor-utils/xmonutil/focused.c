/*
 * Copyright (C) 2026 taylor.fish <contact@taylor.fish>
 *
 * This file is part of xmonutil.
 *
 * xmonutil is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * xmonutil is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with xmonutil. If not, see <https://www.gnu.org/licenses/>.
 *
 * This file contains code derived from dmenu, which is licensed under
 * the MIT/X Consortium License. See 'licenses/dmenu' for a copy of that
 * license and the associated copyright notice.
 */

#include "debug.h"
#include "intersect.h"
#include <X11/extensions/Xinerama.h>
#include <stdbool.h>

int xmonutil_focused_screen(Display *const display) {
    const Window root = DefaultRootWindow(display);
    Window window = None;
    int revert = 0;
    XGetInputFocus(display, &window, &revert);

    bool success = false;
    int x = 0;
    int y = 0;
    int width = 0;
    int height = 0;

    if (window == None || window == PointerRoot || window == root) {
        DEBUG_PRINT("using pointer coordinates\n");
        Window root_;
        Window child;
        int win_x;
        int win_y;
        unsigned int mask;
        success = XQueryPointer(
            display,
            root,
            &root_,
            &child,
            &x,
            &y,
            &win_x,
            &win_y,
            &mask
        );
    } else {
        while (true) {
            Window root_;
            Window parent = None;
            Window *children = NULL;
            unsigned int num_children;
            DEBUG_PRINT("calling XQueryTree\n");
            XQueryTree(
                display,
                window,
                &root_,
                &parent,
                &children,
                &num_children
            );
            XFree(children);
            if (parent == window || parent == root || parent == None) {
                DEBUG_PRINT("done traversing\n");
                break;
            }
            window = parent;
        }
        XWindowAttributes attrs;
        if (XGetWindowAttributes(display, window, &attrs)) {
            DEBUG_PRINT("got window attributes\n");
            x = attrs.x;
            y = attrs.y;
            width = attrs.width;
            height = attrs.height;
            success = true;
        }
    }

    if (!success) {
        return 0;
    }

    DEBUG_PRINT("(%d, %d) %dx%d\n", x, y, width, height);
    if (x < 0) x = 0;
    if (y < 0) y = 0;
    if (width < 1) width = 1;
    if (height < 1) height = 1;

    int num_screens = 0;
    XineramaScreenInfo * const info =
        XineramaQueryScreens(display, &num_screens);

    long max_area = 0;
    int screen = 0;
    for (int i = 0; i < num_screens; ++i) {
        const long area = intersect(
            x,
            y,
            width,
            height,
            info[i].x_org,
            info[i].y_org,
            info[i].width,
            info[i].height
        );
        DEBUG_PRINT("area %d is %ld\n", i, area);
        if (area > max_area) {
            screen = info[i].screen_number;
            max_area = area;
        }
    }
    XFree(info);
    return screen;
}
