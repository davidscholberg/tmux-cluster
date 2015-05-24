### tmux-cluster

tmux-cluster is a wrapper script for [tmux](http://tmux.sourceforge.net/) that aims to be fully compatible with [clusterssh](https://github.com/duncs/clusterssh) clusters configs.

tmux-cluster is written in pure shell and only depends on tmux and standard unix utils (grep, sed, awk, cut, etc.).

#### Usage

```
Usage: tmc [OPTIONS] [CLUSTERNAME]

Options:
    -h              Display help message and quit
    -d              Dump space-separated list of hosts in CLUSTERNAME
    -c CLUSTERLINE  Create custom cluster
                        CLUSTERLINE is treated as a clusters config line.
                        This option conflicts with passing CLUSTERNAME.
                        The name used for the cluster must not exist in the
                            clusters config.
```

tmux-cluster will look for your clusterssh clusters config at `$HOME/.clusterssh/clusters`. See the [configuration](#configuration) section for more info on the configuration syntax.

A new session will be created with the name `cluster-CLUSTERNAME`. All of the hosts specified by `CLUSTERNAME` will be in a single window with a tiled layout, and the panes will be synchronized.

Note that if the `-c` option is used, then passing `CLUSTERNAME` is invalid; the `CLUSTERNAME` used is the first element of `CLUSTERLINE`, since `CLUSTERLINE` is treated exactly as a clusters config line.

It is best to run tmux-cluster outside of an attached tmux session, otherwise you'll end up with a nested tmux instance.

#### Why tmux-cluster?

Question: Why does tmux-cluster exist? There are boatloads of clusterssh tmux wrappers out there already.

Answer: [Configuration](#configuration), [performance](#performance), and [error reporting](#error-reporting).

##### Configuration

When one googles "tmux clusterssh", most of the results are for scripts that purport to be clusterssh-like, but they don't actually support clusterssh clusters files.

Clusterssh clusters files have a powerful configuration format that allows one to easily build up hierarchical groupings of servers. Being able to define a cluster and then use that cluster in the definition of other clusters is a huge benefit that many clusterssh-like tmux wrappers lack.

Here is an example clusterssh clusters file:

```
# first cluster, consisting of host1, host2, and host3
cluster1 host1 host2 host3

# second cluster, consisting of all hosts from first cluster as well as host4 and host5
cluster2 cluster1 host4 host5
```

[lowens/tmux-cssh](https://github.com/lowens/tmux-cssh) seems to support clusterssh clusters files, but (as of this writing) it doesn't seem to support using cluster names inside other cluster definitions for building cluster hierarchies.

[dennishafemann/tmux-cssh](https://github.com/dennishafemann/tmux-cssh) does support building cluster hierarchies, but it uses a different configuration format that is not compatible with clusterssh clusters files and is not as straightforward.

##### Performance

tmux-cluster should perform much faster than most of the clusterssh tmux wrappers out there because of how tmux-cluster passes tmux commands to tmux. Most other clusterssh tmux wrappers make individual calls to tmux for every single tmux command that needs to be run. tmux-cluster, on the other hand, makes a list of native tmux commands first, places this list of commands into a temporary file, and then passes these commands to tmux with a single call to tmux's `source-file` command. This makes tmux-cluster very fast, even if you have much more than a handful of hosts in a particular cluster.

##### Error reporting

tmux-cluster will alert you of every single host that failed to connect by holding open the panes that contain the failed connections until you press enter. This way, you can easily see which hosts failed instead of trying to figure it out manually by comparing open panes with the list of hosts that are supposed to be in the cluster.

#### TODO

* Add ability to specify multiple clusters on command line, each one creating a different session.
* Add command line option to specify a different pane layout to use instead of the default `tiled` layout.
* Add command line option to disable pane synchronization.
* Add command line option to specify path to clusterssh config.
* Make tmux-cluster match clusterssh's behavior of using the "default" cluster if no cluster is specified.
* Add command line option to specify path to custom ssh config.
