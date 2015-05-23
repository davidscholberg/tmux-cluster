### tmux-cluster

tmux-cluster is a wrapper script for tmux that aims to be fully compatible with [clusterssh](https://github.com/duncs/clusterssh) clusters configs.

tmux-cluster is written in pure shell and only depends on tmux and standard unix utils (grep, sed, awk, cut, etc.).

#### Usage

`tmc <clustername>`

tmux-cluster will look for your clusterssh clusters config at `$HOME/.clusterssh/clusters`.

A new session will be created with the name `<clustername>-cluster`. All of the hosts specified by `<clustername>` will be in a single window with a tiled layout, and the panes will be synchronized.

It is best to run tmux-cluster outside of an attached tmux session, otherwise you'll end up with a nested tmux instance.

#### Why?

Question: Why does tmux-cluster exist? There are boatloads of clusterssh tmux wrappers out there, right?

Short answer: ease of configuration and better performance.

Long answer:

##### Configuration

When one googles "tmux clusterssh", most of the results are for scripts that purport to be clusterssh-like, but they don't actually support clusterssh clusters files.

Clusterssh clusters files have a powerful configuration format that allows one to easily build up hierarchical groupings of servers. Being able to define a cluster and then use that cluster in the definition of other clusters is a huge benefit that many clusterssh-like tmux wrappers lack.

[tmux-cssh](https://github.com/lowens/tmux-cssh) seems to support clusterssh clusters files, but (as of this writing) it doesn't seem to support using cluster names inside other cluster definitions for building cluster hierarchies.

##### Performance

tmux-cluster should perform much faster than most of the clusterssh tmux wrappers out there because of how tmux-cluster passes tmux commands to tmux. Most other clusterssh tmux wrappers make individual calls to tmux for every single tmux command that needs to be run. tmux-cluster, on the other hand, makes a list of native tmux commands first, places this list of commands into a temporary file, and then passes these commands to tmux with a single call to tmux's "source-file" command. This makes tmux-cluster very fast, even if you have much more than a handful of hosts in a particular cluster.

#### TODO

* Add ability to specify multiple clusters on command line, each one creating a different session.
* Add command line option to specify a custom list of hosts to use as a cluster.
* Add command line option to dump host list of a given cluster to stdout.
* Add command line option for help/usage
* Add command line option to specify path to config.
* Make tmux-cluster match clusterssh's behavior of using the "default" cluster if no cluster is specified.
