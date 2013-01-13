#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::bond::static', :type => 'define' do

  context 'incorrect value: ensure' do
    let(:title) { 'bond1' }
    let :params do {
      :ensure    => 'blah',
      :ipaddress => '1.2.3.4',
      :netmask   => '255.255.255.0',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-bond1')}.to raise_error(Puppet::Error, /\$ensure must be either "up" or "down"./)
    end
  end

  context 'incorrect value: ipaddress' do
    let(:title) { 'bond1' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => 'notAnIP',
      :netmask   => '255.255.255.0',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-bond1')}.to raise_error(Puppet::Error, /notAnIP is not an IP address./)
    end
  end

  context 'required parameters' do
    let(:title) { 'bond0' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => '1.2.3.5',
      :netmask   => '255.255.255.0',
    }
    end
    let :facts do {
      :macaddress_bond0 => 'fe:fe:fe:aa:aa:aa',
    }
    end
    it { should contain_file('ifcfg-bond0').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-bond0'
    )}
    it 'should contain File[ifcfg-bond0] with required contents' do
      verify_contents(subject, 'ifcfg-bond0', [
        'DEVICE=bond0',
        'BOOTPROTO=none',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.5',
        'NETMASK=255.255.255.0',
        'PEERDNS=no',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_exec('ifup-bond0').with(
      :command     => '/sbin/ifdown bond0; /sbin/ifup bond0',
      :refreshonly => true
    )}
    it { should contain_augeas('modprobe.conf_bond0').with(
      :context => '/files/etc/modprobe.conf',
      :changes => ['set alias[last()+1] bond0', 'set alias[last()]/modulename bonding'],
      :onlyif  => "match alias[*][. = 'bond0'] size == 0"
    )}
  end

  context 'optional parameters' do
    let(:title) { 'bond0' }
    let :params do {
      :ensure       => 'down',
      :ipaddress    => '1.2.3.5',
      :netmask      => '255.255.255.0',
      :gateway      => '1.2.3.1',
      :mtu          => '9000',
      :ethtool_opts => 'speed 1000 duplex full autoneg off',
      :bonding_opts => 'mode=active-backup miimon=100',
      :peerdns      => true,
      :dns1         => '3.4.5.6',
      :dns2         => '5.6.7.8',
      :domain       => 'somedomain.com',
    }
    end
    it { should contain_file('ifcfg-bond0').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-bond0'
    )}
    it 'should contain File[ifcfg-bond0] with required contents' do
      verify_contents(subject, 'ifcfg-bond0', [
        'DEVICE=bond0',
        'BOOTPROTO=none',
        'ONBOOT=no',
        'HOTPLUG=no',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.5',
        'NETMASK=255.255.255.0',
        'GATEWAY=1.2.3.1',
        'MTU=9000',
        'BONDING_OPTS="mode=active-backup miimon=100"',
        'ETHTOOL_OPTS="speed 1000 duplex full autoneg off"',
        'PEERDNS=yes',
        'DNS1=3.4.5.6',
        'DNS2=5.6.7.8',
        'DOMAIN="somedomain.com"',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_exec('ifdown-bond0').with(
      :command     => '/sbin/ifdown bond0',
      :refreshonly => true
    )}
    it { should contain_augeas('modprobe.conf_bond0').with(
      :context => '/files/etc/modprobe.conf',
      :changes => ['set alias[last()+1] bond0', 'set alias[last()]/modulename bonding'],
      :onlyif  => "match alias[*][. = 'bond0'] size == 0"
    )}
  end

end
