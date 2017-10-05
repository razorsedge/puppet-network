#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::if', :type => 'define' do

  context 'incorrect value: ensure' do
    let(:title) { 'eth1' }
    let :params do {
      :ensure  => 'blah',
      :restart => true,
      :sched   => nil,
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-eth1')}.to raise_error(Puppet::Error, /\$ensure must be either "up" or "down"./)
    end
  end

  context 'required parameters' do
    let(:title) { 'eth0' }
    let :params do {
      :ensure  => 'up',
      :restart => true,
      :sched   => nil,
    }
    end
    let :facts do {
      :osfamily               => 'RedHat',
      :operatingsystem        => 'RedHat',
      :operatingsystemrelease => '6.0',
      :macaddress_eth0        => 'fe:fe:fe:aa:aa:aa',
    }
    end
    it { should contain_file('ifcfg-eth0').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth0',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-eth0] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth0', [
        'DEVICE=eth0',
        'BOOTPROTO=none',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

  context 'optional parameters' do
    let(:title) { 'eth0' }
    let :params do {
      :ensure       => 'down',
      :mtu          => '9000',
      :ethtool_opts => 'speed 1000 duplex full autoneg off',
      :zone         => 'trusted',
      :restart      => true,
      :sched        => nil,
    }
    end
    let :facts do {
      :osfamily               => 'RedHat',
      :operatingsystem        => 'RedHat',
      :operatingsystemrelease => '6.0',
      :macaddress_eth0        => 'fe:fe:fe:aa:aa:aa',
    }
    end
    it { should contain_file('ifcfg-eth0').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth0',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-eth0] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth0', [
        'DEVICE=eth0',
        'BOOTPROTO=none',
        'ONBOOT=no',
        'HOTPLUG=no',
        'TYPE=Ethernet',
        'MTU=9000',
        'ETHTOOL_OPTS="speed 1000 duplex full autoneg off"',
        'ZONE=trusted',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

  context 'optional parameters: restart => false' do
    let(:title) { 'eth0' }
    let :params do {
      :ensure  => 'up',
      :restart => false,
      :sched   => nil,
    }
    end
    let :facts do {
      :osfamily               => 'RedHat',
      :operatingsystem        => 'RedHat',
      :operatingsystemrelease => '6.0',
      :macaddress_eth0        => 'fe:fe:fe:aa:aa:aa',
    }
    end
    it { should contain_file('ifcfg-eth0').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth0',
    )}
    it 'should contain File[ifcfg-eth0] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth0', [
        'DEVICE=eth0',
        'BOOTPROTO=none',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
    it { is_expected.to_not contain_file('ifcfg-eth0').that_notifies('Service[network]') }
  end

end
