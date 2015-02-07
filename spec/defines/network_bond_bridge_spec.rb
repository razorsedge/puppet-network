#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::bond::bridge', :type => 'define' do

  context 'incorrect value: ensure' do
    let(:title) { 'bond1' }
    let :params do {
      :ensure => 'blah',
      :bridge => 'br0',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-bond1')}.to raise_error(Puppet::Error, /\$ensure must be either "up" or "down"./)
    end
  end

  context 'required parameters' do
    let(:title) { 'bond0' }
    let :params do {
      :ensure => 'up',
      :bridge => 'br0',
    }
    end
    let :facts do {
      :osfamily         => 'RedHat',
      :macaddress_bond0 => 'fe:fe:fe:aa:aa:aa',
    }
    end
    it { should contain_file('ifcfg-bond0').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-bond0',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-bond0] with required contents' do
      verify_contents(catalogue, 'ifcfg-bond0', [
        'DEVICE=bond0',
        'BOOTPROTO=none',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'BONDING_OPTS="miimon=100"',
        'PEERDNS=no',
        'BRIDGE=br0',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
    it { should_not contain_augeas('modprobe.conf_bond0') }

    context 'on an older operatingsystem with /etc/modprobe.conf' do
      (['RedHat', 'CentOS', 'OEL', 'OracleLinux', 'SLC', 'Scientific']).each do |os|
        context "for operatingsystem #{os}" do
          (['4.8', '5.9']).each do |osv|
            context "for operatingsystemrelease #{osv}" do
              let :facts do {
                :osfamily               => 'RedHat',
                :operatingsystem        => os,
                :operatingsystemrelease => osv,
              }
              end
              it { should contain_augeas('modprobe.conf_bond0').with(
                :context => '/files/etc/modprobe.conf',
                :changes => ['set alias[last()+1] bond0', 'set alias[last()]/modulename bonding'],
                :onlyif  => "match alias[*][. = 'bond0'] size == 0"
              )}
            end
          end
        end
      end

      (['Fedora']).each do |os|
        context "for operatingsystem #{os}" do
          (['6', '9', '11']).each do |osv|
            context "for operatingsystemrelease #{osv}" do
              let :facts do {
                :osfamily               => 'RedHat',
                :operatingsystem        => os,
                :operatingsystemrelease => osv,
              }
              end
              it { should contain_augeas('modprobe.conf_bond0').with(
                :context => '/files/etc/modprobe.conf',
                :changes => ['set alias[last()+1] bond0', 'set alias[last()]/modulename bonding'],
                :onlyif  => "match alias[*][. = 'bond0'] size == 0"
              )}
            end
          end
        end
      end
    end
  end

  context 'optional parameters' do
    let(:title) { 'bond0' }
    let :params do {
      :ensure       => 'down',
      :bridge       => 'br6',
      :mtu          => '9000',
      :ethtool_opts => 'speed 1000 duplex full autoneg off',
      :bonding_opts => 'mode=active-backup miimon=100',
    }
    end
    let(:facts) {{ :osfamily => 'RedHat' }}
    it { should contain_file('ifcfg-bond0').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-bond0',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-bond0] with required contents' do
      verify_contents(catalogue, 'ifcfg-bond0', [
        'DEVICE=bond0',
        'BOOTPROTO=none',
        'ONBOOT=no',
        'HOTPLUG=no',
        'TYPE=Ethernet',
        'MTU=9000',
        'BONDING_OPTS="mode=active-backup miimon=100"',
        'ETHTOOL_OPTS="speed 1000 duplex full autoneg off"',
        'BRIDGE=br6',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
    it { should_not contain_augeas('modprobe.conf_bond0') }
  end

end
