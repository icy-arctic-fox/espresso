#!/usr/bin/env bash
set -e

readonly resolution=1280x720x24

xvfb-run -a -s "-screen 0 ${resolution}" "$@"
