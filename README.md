## tmux-cluster

tmux-cluster is a wrapper script for [tmux](http://tmux.sourceforge.net/) that aims to be fully compatible with [clusterssh](https://github.com/duncs/clusterssh) clusters configs.

It's a handy tool for administering groups (or "clusters") of servers via ssh, all within the comfort of tmux.

tmux-cluster is written in pure shell and only depends on tmux and standard unix utils (grep, sed, awk, cut, etc.).

### Usage

```
Usage: tmc [OPTIONS] [CLUSTERNAME]

Options:
    -h              Display help message and quit
    -d              Dump space-separated list of hosts in CLUSTERNAME.
                        Conflicts with -t option.
    -t              Dump generated list of tmux commands.
                        Conflicts with -d option.
    -c CLUSTERLINE  Create custom cluster
                        CLUSTERLINE is treated as a clusters config line.
                        This option conflicts with passing CLUSTERNAME.
                        The name used for the cluster must not exist in the
                            clusters config.
    -x EXCLUDES     Space-separated list of hosts to exclude from cluster.
                        The hosts in EXCLUDES will not be connected to.
```

tmux-cluster will look for your clusterssh clusters config at `$HOME/.clusterssh/clusters`. See the [configuration](#configuration) section for more info on the configuration syntax.

A new session will be created with the name `cluster-CLUSTERNAME`. All of the hosts specified by `CLUSTERNAME` will be in a single window with a tiled layout, and the panes will be synchronized.

Note that if the `-c` option is used, then passing `CLUSTERNAME` is invalid; the `CLUSTERNAME` that tmux-cluster uses is the first element of `CLUSTERLINE`, since `CLUSTERLINE` is treated exactly as a clusters config line.

You can run tmux-cluster either from outside or inside an attached tmux instance. In either case, tmux-cluster will automatically attach your terminal to the newly created cluster session.

You can also use tmux-cluster as a tmux plugin (see the [tmux plugin installation](#tmux-plugin-installation) section). When tmux-cluster is installed as a plugin, you can type `prefix + C` to pop open a custom tmux prompt with which to lauch clusters. Anything you type in the prompt will be passed directly to the `tmc` script.

### Installation

There are two ways to install tmux-cluster. You can install it as a stand-alone command line utility or as a tmux plugin. Note that even if you install tmux-cluster as a tmux plugin, you can still use it on the command line if desired.

#### Command line only installation

1. Clone this repository: `git clone https://github.com/davidscholberg/tmux-cluster`
1. Optionally copy or [symlink the tmc script](#symlink-the-tmc-script) into a directory in your `$PATH`.

#### Tmux plugin installation

You may either install the tmux plugin manually or through the [tmux plugin manager](https://github.com/tmux-plugins/tpm).

##### Manual plugin installation

1. Clone this repository: `git clone https://github.com/davidscholberg/tmux-cluster`
1. Add the following to your `~/.tmux.conf` file: `run-shell /path/to/tmux-cluster/tmc.tmux`
1. Reload your tmux config.
1. Optionally [configure the plugin](#plugin-configuration).
1. Optionally copy or [symlink the tmc script](#symlink-the-tmc-script) into a directory in your `$PATH`.

##### Installation via tmux plugin manager

1. Ensure that [tmux plugin manager](https://github.com/tmux-plugins/tpm) is installed.
1. Add `davidscholberg/tmux-cluster` to your list of tmux plugins and install it with `prefix + I`.
1. Optionally [configure the plugin](#plugin-configuration).
1. Optionally copy or [symlink the tmc script](#symlink-the-tmc-script) into a directory in your `$PATH`.
  * The tmux plugin manager automatically clones tmux-cluster into this directory: `~/.tmux/plugins/tmux-cluster/`

##### Plugin configuration

By default, the tmux-cluster plugin uses the keybinding `prefix + C` to open a prompt through which to launch clusters, but you may optionally configure a custom keybinding using the `@tmux_cluster_prompt_key` option in your `~/.tmux/conf` file.

For example:

```
set-option -g @tmux_cluster_prompt_key X
```

Be sure to reload your tmux config.

#### Symlink the tmc script

You may optionally symlink the `tmc` script into a directory in your `$PATH` if you want to be able to run `tmc` on the command line from anywhere.

If your `~/bin` directory is in your `$PATH`, then you can create the symlink as follows:

```
ln -s /path/to/tmux-cluster/tmc ~/bin/
```

### Why tmux-cluster?

Question: Why does tmux-cluster exist? There are boatloads of clusterssh tmux wrappers out there already.

Answer: [Configuration](#configuration), [session handling](#session-handling), [error reporting](#error-reporting), [performance](#performance), and [flexible usage](#flexible-usage).

#### Configuration

When one googles "tmux clusterssh", most of the results are for scripts that purport to be clusterssh-like, but they don't actually support clusterssh clusters files.

Clusterssh clusters files have a simple but powerful configuration format that allows one to easily build up hierarchical groupings of servers. Being able to define a cluster and then use that cluster in the definition of other clusters is a huge benefit that many clusterssh-like tmux wrappers lack.

Here is an example clusterssh clusters file:

```
# first cluster, consisting of host1, host2, and host3
cluster1 host1 host2 host3

# second cluster, consisting of all hosts from first cluster as well as host4 and host5
cluster2 cluster1 host4 host5
```

[lowens/tmux-cssh](https://github.com/lowens/tmux-cssh) seems to support clusterssh clusters files, but (as of this writing) it doesn't seem to support using cluster names inside other cluster definitions for building cluster hierarchies.

[dennishafemann/tmux-cssh](https://github.com/dennishafemann/tmux-cssh) does support building cluster hierarchies, but it uses a different configuration format that is not compatible with clusterssh clusters files and is not as straightforward.

#### Session handling

tmux-cluster uses the name of the specified cluster to build the tmux session name, so that you can have multiple simultaneous tmux-cluster sessions open. The name of the session is of the form `cluster-<name>`, where `<name>` is the name of the specified cluster. Because each session name is preceded with `cluster-`, it's easy to see at a glance which tmux-cluster sessions are open since they'll be grouped together alphabetically.

To give a concrete example, lets say you have the following clusters file:


```
cluster1 host1 host2 host3
cluster2 cluster1 host4 host5
```

If you run `tmc cluster1`, then the name of the session that tmux-cluster creates is `cluster-cluster1`. Running `tmc cluster2` creates the session name `cluster-cluster2`.

If you attempt to open a cluster for which there is already an open tmux session, then tmux-cluster will quit gracefully, informing you that the session name is already taken.

#### Error reporting

tmux-cluster will alert you of every single host that failed to connect by holding open the panes that contain the failed connections until you press enter. This way, you can easily see which hosts failed instead of trying to figure it out manually by comparing open panes with the list of hosts that are supposed to be in the cluster.

#### Performance

tmux-cluster should perform faster than most of the clusterssh tmux wrappers out there because of how tmux-cluster passes tmux commands to tmux. Most other clusterssh tmux wrappers make individual calls to tmux for every single tmux command that needs to be run. tmux-cluster, on the other hand, makes a list of native tmux commands first, places this list of commands into a temporary file, and then passes these commands to tmux with a single call to tmux's `source-file` command. This makes tmux-cluster very fast, even if you have much more than a handful of hosts in a particular cluster.

#### Flexible usage

tmux-cluster will work fine whether you run it from inside or outside a running tmux instance. Additionally, tmux-cluster is available as a tmux plugin, making it very easy to install and use. See the [tmux plugin installation](#tmux-plugin-installation) section for more information.

### TODO

* Add usage examples to README.
* Add ability to resolve cluster names in the EXCLUDES list.
* Add command line option to start a local login shell after ssh exits.
* Add command line option to exclude current host from cluster.
* Add command line option to specify unique suffix to append to session name to allow multiple sessions of the same cluster. Could default to appending 4 digit number.
* Add ability to specify multiple clusters on command line, each one creating a different session.
* Add command line option to specify a different pane layout to use instead of the default `tiled` layout.
* Add command line option to disable pane synchronization.
* Add command line option to specify path to clusterssh config.
* Make tmux-cluster match clusterssh's behavior of using the "default" cluster if no cluster is specified.
* Add command line option to specify path to custom ssh config.
