require 'spec_helper'

describe 'dropsonde' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end

    context "on #{os} with enabled => false" do
      let(:facts) { os_facts }
      let(:params) { { enabled: false } }

      it { is_expected.to contain_cron('submit Puppet telemetry report').with_ensure('absent') }
    end

    context "on #{os} with use_cron => false" do
      let(:facts) { os_facts }
      let(:params) { { use_cron: false } }

      it { is_expected.not_to contain_cron('submit Puppet telemetry report') }
    end
  end
end
