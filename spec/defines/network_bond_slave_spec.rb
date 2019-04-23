#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::bond::slave', :type => 'define' do

  context 'incorrect value: macaddress' do
    let(:title) { 'eth6' }
    let :params do {
      :macaddress => '123456',
      :master     => 'bond0',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-eth6')}.to raise_error(Puppet::Error, /123456 is not a MAC address./)
    end
  end

  context 'required parameters' do
    let(:pre_condition) do
      "
      network::alias { 'bond0':
        ensure         => 'up',
        ipaddress      => '1.2.3.5',
        netmask        => '255.255.255.0',
      }
      "
    end

    let(:title) { 'eth1' }
    let :params do {
      :master     => 'bond0',
    }
    end
    let :facts do {
      :osfamily        => 'RedHat',
      :operatingsystem        => 'RedHat',
      :operatingsystemrelease => '6.0',
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
        'MASTER=bond0',
        'SLAVE=yes',
        'TYPE=Ethernet',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
    it { is_expected.to contain_file('ifcfg-eth1').that_notifies('Service[network]') }
  end

  context 'required parameters, restart => false' do
    let(:pre_condition) do
      "
      network::alias { 'bond0':
        ensure         => 'up',
        ipaddress      => '1.2.3.5',
        netmask        => '255.255.255.0',
      }
      "
    end
    let(:title) { 'eth1' }
    let :params do {
      :macaddress => 'fe:fe:fe:aa:aa:a1',
      :master     => 'bond0',
      :restart    => false,
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
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth1'
    )}
    it 'should contain File[ifcfg-eth1] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth1', [
        'DEVICE=eth1',
        'HWADDR=fe:fe:fe:aa:aa:a1',
        'MASTER=bond0',
        'SLAVE=yes',
        'TYPE=Ethernet',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
    it { is_expected.to_not contain_file('ifcfg-eth1').that_notifies('Service[network]') }
  end

  context 'optional parameters' do
    let(:pre_condition) do
      "
      network::alias { 'bond0':
        ensure         => 'up',
        ipaddress      => '1.2.3.5',
        netmask        => '255.255.255.0',
      }
      "
    end
    let(:title) { 'eth3' }
    let :params do {
      :macaddress   => 'ef:ef:ef:ef:ef:ef',
      :master       => 'bond0',
      :ethtool_opts => 'speed 1000 duplex full autoneg off',
      :userctl      => true,
      :bootproto    => 'dhcp',
      :onboot       => 'yes',

    }
    end
    let :facts do {
      :osfamily        => 'RedHat',
      :operatingsystem        => 'RedHat',
      :operatingsystemrelease => '6.0',
      :macaddress_eth3 => 'fe:fe:fe:aa:aa:aa',
    }
    end
    it { should contain_file('ifcfg-eth3').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth3',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-eth3] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth3', [
        'DEVICE=eth3',
        'HWADDR=ef:ef:ef:ef:ef:ef',
        'MASTER=bond0',
        'SLAVE=yes',
        'TYPE=Ethernet',
        'ETHTOOL_OPTS="speed 1000 duplex full autoneg off"',
        'BOOTPROTO=dhcp',
        'ONBOOT=yes',
        'USERCTL=yes',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

end
