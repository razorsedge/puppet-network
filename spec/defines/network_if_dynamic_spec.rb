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
      verify_contents(subject, 'ifcfg-eth99', [
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
      :ensure       => 'down',
      :macaddress   => 'ef:ef:ef:ef:ef:ef',
      :bootproto    => 'bootp',
      :userctl      => true,
      :mtu          => '1500',
      :ethtool_opts => 'speed 100 duplex full autoneg off',
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
      verify_contents(subject, 'ifcfg-eth99', [
        'DEVICE=eth99',
        'BOOTPROTO=bootp',
        'HWADDR=ef:ef:ef:ef:ef:ef',
        'ONBOOT=no',
        'HOTPLUG=no',
        'TYPE=Ethernet',
        'MTU=1500',
        'ETHTOOL_OPTS="speed 100 duplex full autoneg off"',
        'USERCTL=yes',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

end
