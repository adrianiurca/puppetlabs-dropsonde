# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'dropsonde complete configuration' do
  before(:all) do
    pre_run
  end

  after(:all) do
    remove_cron = <<-MANIFEST
      cron { 'submit Puppet telemetry report':
        ensure => absent,
      }
    MANIFEST
    remove_telemetry = <<-MANIFEST
      file { '/etc/puppetlabs/telemetry.yaml':
        ensure => absent,
        owner => 'root',
      }
    MANIFEST
    # remmove the cron job
    apply_manifest(remove_cron)
    # remove the dropsonde gem
    run_shell('yes | /opt/puppetlabs/puppet/bin/gem uninstall dropsonde')
    # remove telemetry.yaml
    apply_manifest(remove_telemetry)
  end
  it 'runs successfully' do
    pp = <<-MANIFEST
      class { 'dropsonde':
        disable   => ['puppetfiles', 'modules'],
        update    => false,
        cachepath => '/var/cache',
        ttl       => 21,
      }
    MANIFEST
    idempotent_apply(pp)
  end

  it 'is installed' do
    expect(run_shell('/opt/puppetlabs/puppet/bin/gem list | grep dropsonde').exit_code).to eq(0)
  end

  it 'has configigured properly for complete configuration' do
    run_shell('cat /etc/puppetlabs/telemetry.yaml') do |result|
      telemetry_config = YAML.safe_load(result.stdout)
      expect(result.exit_code).to eq(0)
      expect(telemetry_config['disable']).to eq(['puppetfiles', 'modules'])
      expect(telemetry_config['update']).to be false
      expect(telemetry_config['cachepath']).to eq('/var/cache')
      expect(telemetry_config['ttl']).to eq(21)
    end
  end

  it 'set the crontab' do
    expect(run_shell('crontab -l | grep /opt/puppetlabs/puppet/bin/dropsonde').exit_code).to eq(0)
  end
end
