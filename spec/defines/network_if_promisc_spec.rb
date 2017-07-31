#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::if::promisc', :type => 'define' do

  context 'required parameters' do
    let(:title) { 'eth1' }
    let :params do {
      :ensure => 'up',
    }
    end
    let :facts do {
      :osfamily        => 'RedHat',
      :operatingsystem           => 'RedHat',
      :operatingsystemrelease    => '6.0',
      :operatingsystemmajrelease => '6',
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
        'PEERDNS=no',
        'PROMISC=yes',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
    it { should contain_file('/sbin/ifup-local') }
    it { should contain_file('/sbin/ifdown-local') }
    it { should contain_file('ifup-local-promisc').with(
      :ensure => 'file',
      :mode   => '0755',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/sbin/ifup-local-promisc',
      :source => 'puppet:///modules/network/promisc/ifup-local-promisc_6'
    )}
    it { should contain_file('ifdown-local-promisc').with(
      :ensure => 'file',
      :mode   => '0755',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/sbin/ifdown-local-promisc',
      :source => 'puppet:///modules/network/promisc/ifdown-local-promisc_6'
    )}
  end

  context 'optional parameters' do
    let(:title) { 'eth3' }
    let :params do {
      :ensure       => 'up',
      :macaddress   => 'ef:ef:ef:ef:ef:ef',
    }
    end
    let :facts do {
      :osfamily        => 'RedHat',
      :operatingsystem           => 'RedHat',
      :operatingsystemrelease    => '6.0',
      :operatingsystemmajrelease => '6',
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
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'PEERDNS=no',
        'PROMISC=yes',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

end
