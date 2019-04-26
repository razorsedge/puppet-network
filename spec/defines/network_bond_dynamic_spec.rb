#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::bond::dynamic', :type => 'define' do

  context 'incorrect value: ensure' do
    let(:title) { 'bond1:1' }
    let :params do {
      :ensure => 'blah'
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-bond1:1')}.to raise_error(Puppet::Error, /expects a match for Enum\['down', 'up'\]/)
    end
  end

  context 'required parameters' do
    let(:title) { 'bond2' }
    let :params do {
      :ensure => 'up',
    }
    end
    let :facts do {
      :os         => {
        :family => 'RedHat',
        :name   => 'RedHat',
        :release => {
          :major => '6'
        }
      },
      :networking => {
        :interfaces => {
          :bond2 => {
            :mac => 'ff:aa:ff:aa:ff:aa'
          }
        }
      }
    }
    end
    it { should contain_file('ifcfg-bond2').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-bond2',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-bond2] with required contents' do
      verify_contents(catalogue, 'ifcfg-bond2', [
        'DEVICE=bond2',
        'BOOTPROTO=dhcp',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'TYPE=Ethernet',
        'BONDING_OPTS="miimon=100"',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
    it { should_not contain_augeas('modprobe.conf_bond2') }

    context 'on an older operatingsystem with /etc/modprobe.conf' do
      (['RedHat', 'CentOS', 'OEL', 'OracleLinux', 'SLC', 'Scientific']).each do |os|
        context "for operatingsystem #{os}" do
          (['4', '5']).each do |osv|
            context "for operatingsystemrelease #{osv}" do
              let :facts do {
                :os => {
                  :family => 'RedHat',
                  :name   => os,
                  :release => {
                    :major => osv
                  }
                }
              }
              end
              it { should contain_augeas('modprobe.conf_bond2').with(
                :context => '/files/etc/modprobe.conf',
                :changes => ['set alias[last()+1] bond2', 'set alias[last()]/modulename bonding'],
                :onlyif  => "match alias[*][. = 'bond2'] size == 0"
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
                :os => {
                  :family => 'RedHat',
                  :name   => os,
                  :release => {
                    :major => osv
                  }
                }
              }
              end
              it { should contain_augeas('modprobe.conf_bond2').with(
                :context => '/files/etc/modprobe.conf',
                :changes => ['set alias[last()+1] bond2', 'set alias[last()]/modulename bonding'],
                :onlyif  => "match alias[*][. = 'bond2'] size == 0"
              )}
            end
          end
        end
      end
    end
  end

  context 'optional parameters' do
    let(:title) { 'bond2' }
    let :params do {
      :ensure       => 'down',
      :mtu          => '9000',
      :ethtool_opts => 'speed 1000 duplex full autoneg off',
      :bonding_opts => 'mode=active-backup arp_interval=60 arp_ip_target=192.168.1.254',
      :defroute     => 'yes',
      :metric       => '10',
      :zone         => 'trusted',
    }
    end
    let :facts do {
      :os         => {
        :family => 'RedHat',
        :name   => 'RedHat',
        :release => {
          :major => '6',
        }
      },
      :networking => {
        :interfaces => {
          :bond2 => {
            :mac => 'ff:aa:ff:aa:ff:aa'
          }
        }
      }
    }
    end
    it { should contain_file('ifcfg-bond2').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-bond2',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-bond2] with required contents' do
      verify_contents(catalogue, 'ifcfg-bond2', [
        'DEVICE=bond2',
        'BOOTPROTO=dhcp',
        'ONBOOT=no',
        'HOTPLUG=no',
        'TYPE=Ethernet',
        'MTU=9000',
        'BONDING_OPTS="mode=active-backup arp_interval=60 arp_ip_target=192.168.1.254"',
        'ETHTOOL_OPTS="speed 1000 duplex full autoneg off"',
        'DEFROUTE=yes',
        'ZONE=trusted',
        'METRIC=10',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
    it { should_not contain_augeas('modprobe.conf_bond2') }
  end

end
