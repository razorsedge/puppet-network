#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::bond::slave', :type => 'define' do

  context 'incorrect value: ipaddress' do
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
    let(:title) { 'eth1' }
    let :params do {
      :macaddress => 'fe:fe:fe:aa:aa:a1',
      :master     => 'bond0',
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
  end

  context 'optional parameters' do
    let(:title) { 'eth3' }
    let :params do {
      :macaddress   => 'ef:ef:ef:ef:ef:ef',
      :master       => 'bond0',
      :ethtool_opts => 'speed 1000 duplex full autoneg off',
    }
    end
    let :facts do {
      :osfamily        => 'RedHat',
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
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

end
