### tmux-cluster

tmux-cluster is a wrapper script for tmux that aims to be fully compatible with [clusterssh](https://github.com/duncs/clusterssh) clusters configs.

tmux-cluster is written in pure shell and only depends on tmux and standard unix utils (grep, sed, awk, cut, etc.).

#### Usage

`tmc <clustername>`

tmux-cluster will look for your clusterssh clusters config at `$HOME/.clusterssh/clusters` (*TODO:* allow path to config to be passed in via command line option).

A new session will be created with the name `<clustername>-cluster`. All of the hosts specified by `<clustername>` will be in a single window with a tiled layout, and the panes will be synchronized.

It is best to run tmux-cluster outside of an attached tmux session, otherwise you'll end up with a nested tmux instance.
