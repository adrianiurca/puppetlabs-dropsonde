# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'dropsonde base configuration' do
  context 'with use_cron => false' do
    let(:dropsonde_manifest) do
      <<-MANIFEST
        class { 'dropsonde':
          use_cron => false,
        }
      MANIFEST
    end

    after(:all) do
      # remove the dropsonde gem
      run_shell('yes | /opt/puppetlabs/puppet/bin/gem uninstall dropsonde')

      # install necessary deps for running further tests
      if os[:family] == 'redhat' && os[:release].to_i == 7
        run_shell('yum install cronie -y')
      end
      if os[:family] == 'debian' || os[:family] == 'ubuntu'
        run_shell('apt-get install cron -y')
      end
    end

    it 'runs successfully' do
      idempotent_apply(dropsonde_manifest)
    end
  end

  context 'with enabled => true and use_cron => true' do
    let(:dropsonde_manifest) { 'include dropsonde' }

    after(:all) do
      remove_cron = <<-MANIFEST
      cron { 'submit Puppet telemetry report':
        ensure => absent,
      }
      MANIFEST
      # remmove the cron job
      apply_manifest(remove_cron)
      # remove the dropsonde gem
      run_shell('yes | /opt/puppetlabs/puppet/bin/gem uninstall dropsonde')
    end

    it 'runs successfully' do
      idempotent_apply(dropsonde_manifest)
    end

    it 'is installed' do
      expect(run_shell('/opt/puppetlabs/puppet/bin/gem list | grep dropsonde').exit_code).to eq(0)
    end

    it 'has not config file(telemetry.yaml) for base configuration' do
      expect(run_shell('test -f /etc/puppetlabs/telemetry.yaml', expect_failures: true).exit_code).to eq(1)
    end

    it 'set the crontab' do
      expect(run_shell('crontab -l | grep /opt/puppetlabs/puppet/bin/dropsonde').exit_code).to eq(0)
    end
  end

  context 'with enabled => false and use_cron => true' do
    let(:dropsonde_manifest) do
      <<-MANIFEST
        class { 'dropsonde':
          enabled => false,
        }
      MANIFEST
    end

    after(:all) do
      # remove the dropsonde gem
      run_shell('yes | /opt/puppetlabs/puppet/bin/gem uninstall dropsonde')
    end

    it 'runs successfully' do
      idempotent_apply(dropsonde_manifest)
    end

    it 'is installed' do
      expect(run_shell('/opt/puppetlabs/puppet/bin/gem list | grep dropsonde').exit_code).to eq(0)
    end

    it 'cron job is not set' do
      expect(run_shell('crontab -l').stdout).not_to include('/opt/puppetlabs/puppet/bin/dropsonde')
    end
  end
end
