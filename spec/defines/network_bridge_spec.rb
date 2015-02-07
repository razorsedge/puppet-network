#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::bridge', :type => 'define' do

  context 'incorrect value: ensure' do
    let(:title) { 'br77' }
    let :params do {
      :ensure => 'blah',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-br77')}.to raise_error(Puppet::Error, /\$ensure must be either "up" or "down"./)
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
      expect {should contain_file('ifcfg-br77')}.to raise_error(Puppet::Error, /"notABool" is not a boolean./)
    end
  end

  context 'required parameters' do
    let(:title) { 'br1' }
    let :params do {
      :ensure => 'up',
    }
    end
    let :facts do {
      :osfamily => 'RedHat',
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
        'BOOTPROTO=none',
        'ONBOOT=yes',
        'TYPE=Bridge',
        'PEERDNS=no',
        'DELAY=30',
        'STP=no',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

  context 'optional parameters' do
    let(:title) { 'br1' }
    let :params do {
      :ensure        => 'down',
      :userctl       => true,
      :stp           => true,
      :delay         => '1000',
      :bridging_opts => 'hello_time=200 priority=65535',
    }
    end
    let :facts do {
      :osfamily => 'RedHat',
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
        'BOOTPROTO=none',
        'ONBOOT=no',
        'TYPE=Bridge',
        'DELAY=1000',
        'STP=yes',
        'BRIDGING_OPTS="hello_time=200 priority=65535"',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

end
