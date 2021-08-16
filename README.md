# dropsonde

This module installs and manages the [Dropsonde Puppet telemetry client](https://github.com/puppetlabs/dropsonde).
See the documentation on [its repository page](https://github.com/puppetlabs/dropsonde) for information about the project.

#### Table of Contents

1. [Description](#description)
   - [What this module manages](#managed-resources)
2. [Usage - Configuration options](#usage)
3. [Limitations](#limitations)
4. [Development - Guide for contributing to the project](#development)

## Description

We both know that you hate telemetry as much as I do. So what makes this
different? At its core, the purpose and design of this module is for your own
benefit as much as it is for ours. Think back to the time you last visited the
Forge to find a module. Chances are that you discovered many modules that
claimed to solve your problem and it was relatively difficult choosing between
them. Surfacing usage data in a way that lets you signal approval simply by
using a module is the primary goal of this project.

**This means that the best way for you to help yourself find new modules is to
install this telemetry tool and, along with your peers, share your module usage
data.**

### Managed resources:

- Installs the `dropsonde` gem.
- Manages configuration at `/etc/puppetlabs/telemetry.yaml`.
- Manages a weekly cronjob to submit the report at a time randomized for each infrastructure.

## Usage

The simplest use case is just to declare the module and accept defaults:

```puppet
include dropsonde
```

If you prefer, you can configure several settings, such as:

```puppet
class { 'dropsonde':
  disable => ['puppetfiles', 'modules'],
  seed    => 'banana pancakes'
}
```

The full list of options is:

- `disable`
  - An array of metrics that you don't want to report. See the available settings
    by running `/opt/puppetlabs/puppet/bin/dropsonde list`.
- `enable`
  - An array of metrics that you allow to report on. All other metrics will be skipped.
    See the available settings by running `/opt/puppetlabs/puppet/bin/dropsonde list`.
- `update`
  - Set to `false` to prevent the tool from automatically updating its list of
    names of public Forge modules. Only do this if you're behind a firewall that
    blocks access to the Forge and you're planning on manually updating this
    periodically yourself.
- `cachepath`
  - The list of public Forge modules is normally stored in Puppet's `vardir`.
    You may set the path to a different directory here if you'd like.
- `ttl`
  - How many days before the tool updates the list of public Forge modules.
- `seed`
  - If you'd like to change your [Site ID](https://github.com/puppetlabs/dropsonde#privacy)
    then make up and enter a random number or string here.

## use_cron parameter

The use_cron parameter is set to true by default as the module will configure and set a cron job for the dropsonde gem to gather the required information periodically. We have decided to allow users to disable the cron functionality to be able to use this module and the dropsonde gem with different other schedulers. In the example bellow we disable cron as we decided to install the gem on a puppetserver machine where the integrated scheduler will assure the required functionality.
Here is how you disable the cron functionality

```puppet
class { 'dropsonde':
  use_cron => false,
}
```

but also you can set a complex configuration

```puppet
class { 'dropsonde':
  use_cron => false,
  disable  => ['puppetfiles', 'modules'],
  seed     => 'banana pancakes'
}
```

`include dropsonde` or `class { 'dropsonde': }` will set a cron job for dropsonde gem.

the above configuration will install dropsonde gem, will set the seed to 'banana pancakes', will disable `puppetfiles` and `modules`, and
will disable cron functionality

## Limitations

This module is currently only tested on Puppet supported platforms.

## Development

There's very little interesting development going on with the module, but we'd
love to get your help on gathering the right metrics and aggregating them in
ways that provide the most community benefits _without compromising privacy_.

- [Telemetry Client](https://github.com/puppetlabs/dropsonde)
- [Aggregation Queries](https://github.com/puppetlabs/dropsonde-aggregation)
