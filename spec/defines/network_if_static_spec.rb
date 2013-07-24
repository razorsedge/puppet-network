#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::if::static', :type => 'define' do

  context 'incorrect value: ipaddress' do
    let(:title) { 'eth77' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => 'notAnIP',
      :netmask   => '255.255.255.0',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-eth77')}.to raise_error(Puppet::Error, /notAnIP is not an IP address./)
    end
  end

  context 'required parameters' do
    let(:title) { 'eth1' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => '1.2.3.4',
      :netmask   => '255.255.255.0',
    }
    end
    let :facts do {
      :osfamily        => 'RedHat',
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
      verify_contents(subject, 'ifcfg-eth1', [
        'DEVICE=eth1',
        'BOOTPROTO=none',
        'HWADDR=fe:fe:fe:aa:aa:aa',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.4',
        'NETMASK=255.255.255.0',
        'PEERDNS=no',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

  context 'optional parameters' do
    let(:title) { 'eth1' }
    let :params do {
      :ensure       => 'down',
      :ipaddress    => '1.2.3.4',
      :netmask      => '255.255.255.0',
      :gateway      => '1.2.3.1',
      :macaddress   => 'ef:ef:ef:ef:ef:ef',
      :userctl      => true,
      :mtu          => '9000',
      :ethtool_opts => 'speed 1000 duplex full autoneg off',
      :peerdns      => true,
      :dns1         => '3.4.5.6',
      :dns2         => '5.6.7.8',
      :domain       => 'somedomain.com',
    }
    end
    let :facts do {
      :osfamily        => 'RedHat',
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
      verify_contents(subject, 'ifcfg-eth1', [
        'DEVICE=eth1',
        'BOOTPROTO=none',
        'HWADDR=ef:ef:ef:ef:ef:ef',
        'ONBOOT=no',
        'HOTPLUG=no',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.4',
        'NETMASK=255.255.255.0',
        'GATEWAY=1.2.3.1',
        'MTU=9000',
        'ETHTOOL_OPTS="speed 1000 duplex full autoneg off"',
        'PEERDNS=yes',
        'DNS1=3.4.5.6',
        'DNS2=5.6.7.8',
        'DOMAIN="somedomain.com"',
        'USERCTL=yes',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

end
