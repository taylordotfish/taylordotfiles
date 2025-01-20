/*
 * Copyright (C) 2024 taylor.fish <contact@taylor.fish>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

#define _GNU_SOURCE
#include <pulse/pulseaudio.h>
#include <inttypes.h>
#include <poll.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define MIN_DELAY 200000 // microseconds
#define NAME_MAX_LEN 40

typedef struct State {
    bool request_pending;
    struct timespec last_request;
    uint32_t prev_min_index;
    uint32_t prev_max_index;
    uint32_t min_index;
    uint32_t max_index;
} State;

static void on_inputs(
    pa_context * const context,
    const pa_sink_input_info * const input,
    const int eol,
    void * const data
) {
    State * const state = data;
    if (eol) {
        state->request_pending = false;
        state->prev_min_index = state->min_index;
        state->prev_max_index = state->max_index;
        return;
    }
    if (input->index < state->min_index) {
        state->min_index = input->index;
    }
    if (input->index > state->max_index) {
        state->max_index = input->index;
    }
    if (input->index >= state->prev_min_index &&
        input->index <= state->prev_max_index)
    {
        // This input has already been processed.
        return;
    }
    if (!input->has_volume || input->volume.channels <= 0) {
        return;
    }
    pa_cvolume volume = input->volume;
    const int old_percent = pa_cvolume_avg(&volume) * 100 / PA_VOLUME_NORM;
    for (size_t i = 0; i < volume.channels; ++i) {
        if (volume.values[i] >= PA_VOLUME_NORM) {
            return;
        }
        volume.values[i] = PA_VOLUME_NORM;
    }

    printf("Changing volume of \"");
    const char * const name = input->name;
    if (name && strnlen(name, NAME_MAX_LEN + 1) > NAME_MAX_LEN) {
        printf("%.*s...", NAME_MAX_LEN - 3, name);
    } else {
        printf("%s", name);
    }
    printf("\" (%"PRIu32") from %d%% to 100%%\n", input->index, old_percent);
    pa_cvolume_set(&volume, volume.channels, PA_VOLUME_NORM);
    if (!pa_context_set_sink_input_volume(
        context,
        input->index,
        &volume,
        NULL,
        NULL
    )) {
        fprintf(
            stderr,
            "warning: pa_context_set_sink_input_volume() failed\n"
        );
    }
}

#define STOP_LOOP (-2)

// Returns the requested timeout for the next call to `pa_mainloop_prepare()`,
// or `STOP_LOOP` to stop the loop and exit the program.
static int update(State * const state, pa_context * const context) {
    const pa_context_state_t pa_state = pa_context_get_state(context);
    if (!PA_CONTEXT_IS_GOOD(pa_state)) {
        printf("connection lost (status: %d)\n", (int)pa_state);
        return STOP_LOOP;
    }
    if (pa_state != PA_CONTEXT_READY) {
        return -1;
    }
    if (state->request_pending) {
        return -1;
    }
    struct timespec time;
    if (clock_gettime(CLOCK_MONOTONIC, &time) != 0) {
        perror("clock_gettime() failed");
        exit(1);
    }
    unsigned long elapsed = MIN_DELAY;
    if (time.tv_sec - state->last_request.tv_sec <= 1) {
        elapsed = (time.tv_sec - state->last_request.tv_sec) * 1000000 +
                  (time.tv_nsec - state->last_request.tv_nsec) / 1000;
    }
    if (elapsed < MIN_DELAY) {
        return MIN_DELAY - elapsed;
    }
    if (clock_gettime(CLOCK_MONOTONIC, &state->last_request) != 0) {
        perror("clock_gettime() failed");
        exit(1);
    }
    state->request_pending = true;
    state->min_index = 1;
    state->max_index = 0;
    if (!pa_context_get_sink_input_info_list(context, on_inputs, state)) {
        fprintf(stderr, "pa_context_get_sink_input_info_list() failed\n");
        exit(1);
    }
    return -1;
}

static volatile sig_atomic_t termination_requested = 0;

static void on_sigint(const int signum) {
    (void)signum;
    termination_requested = 1;
}

static int mainloop_poll(
    struct pollfd * const fds,
    const unsigned long nfds,
    const int timeout,
    void * const data
) {
    const struct timespec tmo = {
        .tv_sec = timeout / 1000,
        .tv_nsec = (timeout % 1000) * 1000000,
    };
    return ppoll(fds, nfds, &tmo, data);
}

int main(void) {
    static const int signals[] = { SIGHUP, SIGINT, SIGQUIT, SIGTERM };
    sigset_t blocked;
    sigemptyset(&blocked);
    for (size_t i = 0; i < sizeof(signals) / sizeof(*signals); ++i) {
        sigaddset(&blocked, signals[i]);
    }

    sigset_t oldsigset;
    if (sigprocmask(SIG_BLOCK, &blocked, &oldsigset) != 0) {
        perror("sigprocmask() failed");
        exit(1);
    }
    struct sigaction action = {
        .sa_handler = on_sigint,
    };
    sigemptyset(&action.sa_mask);
    for (size_t i = 0; i < sizeof(signals) / sizeof(*signals); ++i) {
        sigaction(signals[i], &action, NULL);
    }

    pa_mainloop * const loop = pa_mainloop_new();
    if (!loop) {
        fprintf(stderr, "pa_mainloop_new() failed\n");
        exit(1);
    }
    pa_mainloop_set_poll_func(loop, mainloop_poll, &oldsigset);
    pa_mainloop_api * const api = pa_mainloop_get_api(loop);
    if (!api) {
        fprintf(stderr, "pa_mainloop_get_api() failed\n");
        exit(1);
    }
    pa_context * const context = pa_context_new(api, "pulse-max-volume");
    if (!context) {
        fprintf(stderr, "pa_context_new() failed\n");
        exit(1);
    }
    const int conn_status = pa_context_connect(
        context,
        NULL,
        PA_CONTEXT_NOAUTOSPAWN,
        NULL
    );
    if (conn_status < 0) {
        fprintf(stderr, "pa_context_connect() failed: %d\n", conn_status);
        exit(1);
    }

    State state = {
        .request_pending = false,
    };
    while (true) {
        const int timeout = update(&state, context);
        if (timeout == STOP_LOOP) {
            break;
        }
        const int prep_status = pa_mainloop_prepare(loop, timeout);
        if (prep_status < 0) {
            fprintf(stderr, "pa_mainloop_prepare() failed: %d\n", prep_status);
            exit(1);
        }
        const int poll_status = pa_mainloop_poll(loop);
        if (poll_status < 0) {
            fprintf(stderr, "pa_mainloop_poll() failed: %d\n", poll_status);
            exit(1);
        }
        if (termination_requested) {
            break;
        }
        const int num_dispatched = pa_mainloop_dispatch(loop);
        if (num_dispatched < 0) {
            fprintf(
                stderr,
                "pa_mainloop_dispatch() failed: %d\n",
                num_dispatched
            );
            exit(1);
        }
    }
    pa_context_set_state_callback(context, NULL, NULL);
    pa_context_disconnect(context);
    pa_context_unref(context);
    pa_mainloop_free(loop);
}
