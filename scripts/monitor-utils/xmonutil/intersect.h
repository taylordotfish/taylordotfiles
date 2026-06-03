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

#ifndef XMONUTIL_INTERSECT_H
#define XMONUTIL_INTERSECT_H

static inline long intersect(
    const long x1,
    const long y1,
    const long w1,
    const long h1,
    const long x2,
    const long y2,
    const long w2,
    const long h2
) {
    const long x1_end = x1 + w1;
    const long y1_end = y1 + h1;
    const long x2_end = x2 + w2;
    const long y2_end = y2 + h2;

    const long x = x1 < x2 ? x2 : x1;
    const long y = y1 < y2 ? y2 : y1;
    const long x_end = x1_end < x2_end ? x1_end : x2_end;
    const long y_end = y1_end < y2_end ? y1_end : y1_end;

    if (x_end < x || y_end < y) {
        return 0;
    }
    return (x_end - x) * (y_end - y);
}

#endif
