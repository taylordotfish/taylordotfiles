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

#ifndef XMONUTIL_FOCUSED_H
#define XMONUTIL_FOCUSED_H

#include <X11/Xlib.h>

int xmonutil_focused_screen(Display *const display);

#endif
