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

static int max_intersecting_screen(
    const XineramaScreenInfo * const info,
    const int num_screens,
    int x,
    int y,
    int width,
    int height
) {
    DEBUG_PRINT("finding screen for %dx%d+%d+%d\n", width, height, x, y);
    long max_area = 0;
    int screen = -1;
    if (width < 0) {
        x += width;
        width *= -1;
    }
    if (height < 0) {
        y += height;
        height *= -1;
    }
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
    return screen;
}

int xmonutil_focused_screen(Display * const display) {
    const Window root = DefaultRootWindow(display);
    Window window = None;
    int revert = 0;
    XGetInputFocus(display, &window, &revert);

    bool success = false;
    int x = 0;
    int y = 0;
    int width = 0;
    int height = 0;
    int screen = 0;

    int num_screens = 0;
    XineramaScreenInfo * const info =
        XineramaQueryScreens(display, &num_screens);

    if (window != None && window != PointerRoot && window != root) {
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
        screen = max_intersecting_screen(
            info,
            num_screens,
            x,
            y,
            width,
            height
        );
        if (screen >= 0) {
            goto free_screens;
        }
    }

    DEBUG_PRINT("using pointer coordinates\n");
    Window root_;
    Window child;
    int win_x;
    int win_y;
    unsigned int mask;
    x = 0;
    y = 0;
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

    if (!success) {
        DEBUG_PRINT("XQueryPointer failed\n");
        return 0;
    }

    width = 1;
    height = 1;
    screen = max_intersecting_screen(
        info,
        num_screens,
        x,
        y,
        width,
        height
    );
    if (screen < 0) {
        screen = 0;
    }

free_screens:
    XFree(info);
    return screen;
}
