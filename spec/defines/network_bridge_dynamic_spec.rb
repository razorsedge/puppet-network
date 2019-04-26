#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::bridge::dynamic', :type => 'define' do

  context 'incorrect value: ensure' do
    let(:title) { 'br77' }
    let :params do {
      :ensure => 'blah',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-br77')}.to raise_error(Puppet::Error, /expects a match for Enum\['down', 'up'\]/)
    end
  end

  context 'incorrect value: stp' do
    let(:title) { 'br77' }
    let :params do {
      :ensure => 'up',
      :stp    => 'notABool',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-br77')}.to raise_error(Puppet::Error, /expects a Boolean/)
    end
  end

  context 'required parameters' do
    let(:title) { 'br1' }
    let :params do {
      :ensure => 'up',
    }
    end
    let :facts do {
      :os => {
        :family => 'RedHat',
        :name   => 'RedHat',
        :release => {
          :major => '6',
        }
      }
    }
    end
    it { should contain_file('ifcfg-br1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-br1',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-br1] with required contents' do
      verify_contents(catalogue, 'ifcfg-br1', [
        'DEVICE=br1',
        'BOOTPROTO=dhcp',
        'ONBOOT=yes',
        'TYPE=Bridge',
        'PEERDNS=no',
        'DELAY=30',
        'STP=no',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
    it { is_expected.to contain_file('ifcfg-br1').that_notifies('Service[network]') }
    it { should contain_package('bridge-utils') }
  end

  context 'required parameters, restart => false' do
    let(:title) { 'br1' }
    let :params do {
      :ensure  => 'up',
      :restart => false,
    }
    end
    let :facts do {
      :os => {
        :family => 'RedHat'
      }
    }
    end
    it { should contain_file('ifcfg-br1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-br1'
    )}
    it 'should contain File[ifcfg-br1] with required contents' do
      verify_contents(catalogue, 'ifcfg-br1', [
        'DEVICE=br1',
        'BOOTPROTO=dhcp',
        'ONBOOT=yes',
        'TYPE=Bridge',
        'PEERDNS=no',
        'DELAY=30',
        'STP=no',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
    it { is_expected.to_not contain_file('ifcfg-br1').that_notifies('Service[network]') }
    it { should contain_package('bridge-utils') }
  end

  context 'optional parameters' do
    let(:title) { 'br1' }
    let :params do {
      :ensure        => 'down',
      :bootproto     => 'bootp',
      :userctl       => true,
      :stp           => true,
      :delay         => '1000',
      :bridging_opts => 'hello_time=200 priority=65535',
    }
    end
    let :facts do {
      :os => {
        :family => 'RedHat'
      }
    }
    end
    it { should contain_file('ifcfg-br1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-br1',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-br1] with required contents' do
      verify_contents(catalogue, 'ifcfg-br1', [
        'DEVICE=br1',
        'BOOTPROTO=bootp',
        'ONBOOT=no',
        'TYPE=Bridge',
        'DELAY=1000',
        'STP=yes',
        'BRIDGING_OPTS="hello_time=200 priority=65535"',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
    it { should contain_package('bridge-utils') }
  end

end
