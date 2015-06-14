#!/usr/bin/env bash

# Copyright 2015 David Scholberg <recombinant.vector@gmail.com>

# This file is part of tmux-cluster.
#
# tmux-cluster is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# tmux-cluster is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with tmux-cluster.  If not, see <http://www.gnu.org/licenses/>.

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PROMPT_KEY_OPTION="@tmux_cluster_prompt_key"
PROMPT_KEY="$(tmux show-options -g | grep -E "^$PROMPT_KEY_OPTION" | cut -f 2 -d ' ' | sed 's/"//g')"

if [ -z "$PROMPT_KEY" ]; then
	PROMPT_KEY="C"
fi

# we redirect stderr to stdout so that it gets displayed in the tmux pane (see run-shell)
tmux bind-key "$PROMPT_KEY" command-prompt -p "launch cluster:" "run-shell '$CURRENT_DIR/tmc %% 2>&1'"
