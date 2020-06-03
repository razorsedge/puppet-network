#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::service', :type => 'class' do

  context 'on RHEL7' do
    let(:facts) {{
      :osfamily               => 'RedHat',
      :operatingsystemrelease => '7.0',
    }}
    it { should contain_service('network').with(
      :ensure     => 'running',
      :enable     => true,
      :hasrestart => true,
      :hasstatus  => true,
    )}
  end

  context 'on RHEL8' do
    let(:facts) {{
      :osfamily               => 'RedHat',
      :operatingsystemrelease => '8.0',
    }}
    it { should contain_exec('restart_network').with(
      :command     => '/usr/bin/nmcli networking off ; /usr/bin/systemctl restart NetworkManager ; /usr/bin/nmcli networking on',
      :group       => 'root',
      :user        => 'root',
      :refreshonly => true,
    )}
  end
end
