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
 */

#include "debug.h"
#include "focused.h"
#include <X11/Xlib.h>
#include <X11/extensions/Xinerama.h>
#include <X11/extensions/Xrandr.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdnoreturn.h>
#include <stdlib.h>
#include <string.h>

static const char * const usage = "\
Usage: xmonutil <command>\n\
\n\
Commands:\n\
  screens\n\
    List Xinerama screens as JSON\n\
  outputs\n\
    List RandR outputs as JSON\n\
  focused\n\
    Get focused screen number\n\
  delprop <screen> <property>\n\
    Remove <property> from outputs of <screen>\n\
";

typedef enum Command {
    command_none,
    command_screens,
    command_outputs,
    command_focused,
    command_delprop,
} Command;

static void print_screens(Display * const display) {
    int num_screens = 0;
    XineramaScreenInfo * const info =
        XineramaQueryScreens(display, &num_screens);

    putchar('[');
    for (int i = 0; i < num_screens; ++i) {
        printf(
            "%s{\"screen\":%d,\"x\":%d,\"y\":%d,\"width\":%d,\"height\":%d}",
            i == 0 ? "" : ",",
            i,
            info[i].x_org,
            info[i].y_org,
            info[i].width,
            info[i].height
        );
        if (info[i].screen_number != i) {
            fprintf(
                stderr,
                "warning: screen number (%d) differs from index (%d)",
                info[i].screen_number,
                i
            );
        }
    }
    puts("]");
    XFree(info);
}

static void write_json_string(FILE * const stream, const char *s) {
    fputc('"', stream);
    for (; *s != '\0'; ++s) {
        if ((unsigned char)*s <= 0x1f || *s == '\\' || *s == '"') {
            fprintf(stream, "\\u%04x", (unsigned char)*s);
        } else {
            fputc(*s, stream);
        }
    }
    fputc('"', stream);
}

static void print_outputs(Display * const display) {
    const Window root = DefaultRootWindow(display);
    XRRScreenResources * const resources =
        XRRGetScreenResources(display, root);
    const int ncrtc = resources ? resources->ncrtc : 0;

    putchar('[');
    bool any = false;
    for (int i = 0; i < ncrtc; ++i) {
        const RRCrtc crtc = resources->crtcs[i];
        XRRCrtcInfo * const crtc_info =
            XRRGetCrtcInfo(display, resources, crtc);

        XRROutputInfo * const output_info = crtc_info && crtc_info->noutput > 0
            ? XRRGetOutputInfo(display, resources, crtc_info->outputs[0])
            : NULL;
        XRRFreeCrtcInfo(crtc_info);

        if (output_info && output_info->name) {
            printf("%s{\"output\":", any ? "," : "");
            write_json_string(stdout, output_info->name);
            printf(",\"screen\":%d}", i);
            any = true;
        }
        XRRFreeOutputInfo(output_info);
    }
    puts("]");
    XRRFreeScreenResources(resources);
}

static void print_focused(Display * const display) {
    printf("%d\n", xmonutil_focused_screen(display));
}

static void remove_property(
    Display * const display,
    const int argc,
    char ** const argv
) {
    if (argc < 2) {
        fputs("error: missing argument\n", stderr);
        return;
    }
    int screen = 0;
    if (sscanf(argv[0], "%d", &screen) != 1 || screen < 0) {
        fputs("error: failed to parse screen\n", stderr);
        return;
    }

    const Window root = DefaultRootWindow(display);
    XRRScreenResources * const resources =
        XRRGetScreenResources(display, root);
    if (!resources || screen >= resources->ncrtc) {
        fprintf(stderr, "error: screen %d does not exist\n", screen);
        goto free_screen_resources;
    }

    const char * const property = argv[1];
    const Atom atom = XInternAtom(display, property, true);
    if (atom == None) {
        DEBUG_PRINT("property atom is not interned\n");
        goto free_screen_resources;
    }

    const RRCrtc crtc = resources->crtcs[screen];
    XRRCrtcInfo * const crtc_info = XRRGetCrtcInfo(display, resources, crtc);
    if (!crtc_info) {
        goto free_screen_resources;
    }

    for (int i = 0; i < crtc_info->noutput; ++i) {
        const RROutput output = crtc_info->outputs[i];
        int nprops = 0;
        Atom * const props = XRRListOutputProperties(display, output, &nprops);
        for (int p = 0; p < nprops; ++p) {
            if (props[p] == atom) {
                DEBUG_PRINT("found property on output %d\n", i);
                XRRDeleteOutputProperty(display, output, atom);
                break;
            }
        }
        XFree(props);
    }
    XRRFreeCrtcInfo(crtc_info);
free_screen_resources:
    XRRFreeScreenResources(resources);
}

static noreturn void usage_error(void) {
    fputs("See `xmonutil --help` for usage information.\n", stderr);
    exit(EXIT_FAILURE);
}

int main(const int argc, char ** const argv) {
    if (argc <= 1) {
        fputs("error: missing command\n", stderr);
        usage_error();
    }

    Command command = command_none;
    if (strcmp(argv[1], "screens") == 0) {
        command = command_screens;
    } else if (strcmp(argv[1], "outputs") == 0) {
        command = command_outputs;
    } else if (strcmp(argv[1], "focused") == 0) {
        command = command_focused;
    } else if (strcmp(argv[1], "delprop") == 0) {
        command = command_delprop;
    } else if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0) {
        fputs(usage, stdout);
        return EXIT_SUCCESS;
    } else {
        fputs("error: unknown command\n", stderr);
        usage_error();
    }

    Display * const display = XOpenDisplay(NULL);
    if (!display) {
        fprintf(stderr, "error: cannot open display\n");
        return EXIT_FAILURE;
    }
    switch (command) {
        case command_none:
            break;
        case command_screens:
            print_screens(display);
            break;
        case command_outputs:
            print_outputs(display);
            break;
        case command_focused:
            print_focused(display);
            break;
        case command_delprop:
            remove_property(display, argc - 2, argv + 2);
            break;
    }
    XCloseDisplay(display);
}
