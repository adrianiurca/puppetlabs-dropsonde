# @summary Manages the Dropsonde Puppet telementry client and cron job.
#
# In general, you'll just want to include the class, but there are a few
# settings you might care about. If you want to remove any of the computed
# metrics from the report, list them as an array in `$disable` and if you
# want to change the generated site ID, enter a random string as the `$seed`.
#
# @see
#   https://github.com/puppetlabs/dropsonde
#
# @example
#   include dropsonde
# @param [Boolean] enabled
#   Set the cron job for dropsonde weekly report submit
# @param [Boolean] use_cron
#   Enable dropsonde to use the cron provider from the host
# @param [Array] enable
#   Only load these metrics. For example:
#   ```puppet
#     class { 'dropsonde':
#       enable => ['dependencies', 'modules'],
#     }
#   ```
# @param [Array] disable
#   List of metrics to omit. For example:
#   ```puppet
#     class { 'dropsonde':
#       disable => ['puppetfiles', 'environments'],
#     }
#   ```
# @param [String] cachepath
#   Path to cache directory
# @param [Integer] ttl
#   Forge module cache ttl in days
# @param [Boolean] update
#   Auto update the Forge module name cache if expired
# @param [String] seed
#   Any number or string used to generate the randomized site ID
class dropsonde (
  Boolean           $enabled   = true,
  Boolean           $use_cron  = true,
  Optional[Array]   $enable    = undef,
  Optional[Array]   $disable   = undef,
  Optional[String]  $cachepath = undef,
  Optional[Integer] $ttl       = undef,
  Optional[Boolean] $update    = undef,
  Optional[String]  $seed      = undef,
) {

  $config = {
    enable    => $enable,
    disable   => $disable,
    cachepath => $cachepath,
    ttl       => $ttl,
    update    => $update,
    seed      => $seed,
  }.filter |$key, $val| { $val =~ NotUndef }

  $ensure_config = $config.empty ? {
    true  => absent,
    false => file
  }

  file { '/etc/puppetlabs/telemetry.yaml':
    ensure  => $ensure_config,
    owner   => 'root',
    mode    => '0660',
    content => dropsonde::to_yaml($config),
  }


  package { 'dropsonde':
    ensure   => latest,
    provider => puppet_gem,
  }


  $ensure_cron = $enabled ? {
    true  => present,
    false => absent
  }

  if $use_cron {
    cron { 'submit Puppet telemetry report':
      ensure  => $ensure_cron,
      command => '/opt/puppetlabs/puppet/bin/dropsonde submit',
      user    => 'root',
      weekday => fqdn_rand(6),
      hour    => fqdn_rand(23),
      minute  => fqdn_rand(59),
    }
  }
}
