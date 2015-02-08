#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::if::dynamic', :type => 'define' do

  context 'incorrect value: ensure' do
    let(:title) { 'eth77' }
    let :params do {
      :ensure => 'blah',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-eth77')}.to raise_error(Puppet::Error, /\$ensure must be either "up" or "down"./)
    end
  end

  context 'required parameters' do
    let(:title) { 'eth99' }
    let :params do {
      :ensure => 'up',
    }
    end
    let :facts do {
      :osfamily         => 'RedHat',
      :macaddress_eth99 => 'ff:aa:ff:aa:ff:aa',
    }
    end
    it { should contain_file('ifcfg-eth99').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth99',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-eth99] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth99', [
        'DEVICE=eth99',
        'BOOTPROTO=dhcp',
        'HWADDR=ff:aa:ff:aa:ff:aa',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

  context 'optional parameters' do
    let(:title) { 'eth99' }
    let :params do {
      :ensure        => 'down',
      :macaddress    => 'ef:ef:ef:ef:ef:ef',
      :bootproto     => 'bootp',
      :userctl       => true,
      :mtu           => '1500',
      :ethtool_opts  => 'speed 100 duplex full autoneg off',
      :dhcp_hostname => 'hostname',
      :linkdelay     => '5',
    }
    end
    let :facts do {
      :osfamily         => 'RedHat',
      :macaddress_eth99 => 'ff:aa:ff:aa:ff:aa',
    }
    end
    it { should contain_file('ifcfg-eth99').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth99',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-eth99] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth99', [
        'DEVICE=eth99',
        'BOOTPROTO=bootp',
        'HWADDR=ef:ef:ef:ef:ef:ef',
        'ONBOOT=no',
        'HOTPLUG=no',
        'TYPE=Ethernet',
        'MTU=1500',
        'DHCP_HOSTNAME="hostname"',
        'ETHTOOL_OPTS="speed 100 duplex full autoneg off"',
        'USERCTL=yes',
        'LINKDELAY=5',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

  context 'optional parameters - vlan' do
    let(:title) { 'eth45.302' }
    let(:params) {{ :ensure => 'up' }}
    let :facts do {
      :osfamily         => 'RedHat',
      :macaddress_eth45 => 'bb:cc:bb:cc:bb:cc',
    }
    end
    it { should contain_file('ifcfg-eth45.302').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth45.302',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-eth45.302] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth45.302', [
        'DEVICE=eth45.302',
        'BOOTPROTO=dhcp',
        'HWADDR=bb:cc:bb:cc:bb:cc',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

end
