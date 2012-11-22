#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::bond::dynamic', :type => 'define' do

  context 'required parameters' do
    let(:title) { 'bond2' }
    let :params do {
      :ensure => 'up',
    }
    end
    let :facts do {
      :macaddress_bond2 => 'ff:aa:ff:aa:ff:aa',
    }
    end
    it { should contain_file('ifcfg-bond2').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-bond2'
    )}
    it 'should contain File[ifcfg-bond2] with required contents' do
      verify_contents(subject, 'ifcfg-bond2', [
        'DEVICE=bond2',
        'BOOTPROTO=dhcp',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_exec('ifup-bond2').with(
      :command     => '/sbin/ifdown bond2; /sbin/ifup bond2',
      :refreshonly => true
    )}
    it { should contain_augeas('modprobe.conf_bond2').with(
      :context => '/files/etc/modprobe.conf',
      :changes => ['set alias[last()+1] bond2', 'set alias[last()]/modulename bonding'],
      :onlyif  => "match alias[*][. = 'bond2'] size == 0"
    )}
  end

  context 'optional parameters' do
    let(:title) { 'bond2' }
    let :params do {
      :ensure       => 'down',
      :mtu          => '9000',
      :ethtool_opts => 'speed 1000 duplex full autoneg off',
      :bonding_opts => 'mode=active-backup arp_interval=60 arp_ip_target=192.168.1.254',
    }
    end
    let :facts do {
      :macaddress_bond2 => 'ff:aa:ff:aa:ff:aa',
    }
    end
    it { should contain_file('ifcfg-bond2').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-bond2'
    )}
    it 'should contain File[ifcfg-bond2] with required contents' do
      verify_contents(subject, 'ifcfg-bond2', [
        'DEVICE=bond2',
        'BOOTPROTO=dhcp',
        'ONBOOT=no',
        'HOTPLUG=no',
        'TYPE=Ethernet',
        'MTU=9000',
        'BONDING_OPTS="mode=active-backup arp_interval=60 arp_ip_target=192.168.1.254"',
        'ETHTOOL_OPTS="speed 1000 duplex full autoneg off"',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_exec('ifdown-bond2').with(
      :command     => '/sbin/ifdown bond2',
      :refreshonly => true
    )}
    it { should contain_augeas('modprobe.conf_bond2').with(
      :context => '/files/etc/modprobe.conf',
      :changes => ['set alias[last()+1] bond2', 'set alias[last()]/modulename bonding'],
      :onlyif  => "match alias[*][. = 'bond2'] size == 0"
    )}
  end

end
