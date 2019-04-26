#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::if::none', :type => 'define' do
  context 'without parameters' do
    let(:title) { 'eth1' }
    let(:params){
      {
        :ensure => 'up'
      }
    }
    let :facts do {
      :os => {
        :family => 'RedHat'
      },
      :macaddress_eth1 => 'fe:fe:fe:aa:aa:aa',
    }
    end
    it { should contain_file('ifcfg-eth1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth1',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-eth1] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth1', [
        'DEVICE=eth1',
        'BOOTPROTO=none',
        'HWADDR=fe:fe:fe:aa:aa:aa',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

  context 'optional parameters' do
    let(:title) { 'eth1' }
    let :params do {
      :ensure       => 'down',
      :macaddress   => 'ef:ef:ef:ef:ef:ef',
      :userctl      => true,
      :mtu          => '9000',
      :ethtool_opts => 'speed 1000 duplex full autoneg off',
      :linkdelay    => '5',
    }
    end
    let :facts do {
      :os => {
        :family => 'RedHat'
      },
      :macaddress_eth1 => 'fe:fe:fe:aa:aa:aa',
    }
    end
    it { should contain_file('ifcfg-eth1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth1',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-eth1] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth1', [
        'DEVICE=eth1',
        'BOOTPROTO=none',
        'HWADDR=ef:ef:ef:ef:ef:ef',
        'ONBOOT=no',
        'HOTPLUG=no',
        'TYPE=Ethernet',
        'MTU=9000',
        'ETHTOOL_OPTS="speed 1000 duplex full autoneg off"',
        'USERCTL=yes',
        'LINKDELAY=5',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end
end
