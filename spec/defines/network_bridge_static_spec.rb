#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::bridge::static', :type => 'define' do

  context 'incorrect value: ensure' do
    let(:title) { 'br77' }
    let :params do {
      :ensure    => 'blah',
      :ipaddress => '1.2.3.4',
      :netmask   => '255.255.255.0',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-br77')}.to raise_error(Puppet::Error, /expects a match for Enum\['down', 'up'\]/)
    end
  end

  context 'incorrect value: ipaddress' do
    let(:title) { 'br77' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => 'notAnIP',
      :netmask   => '255.255.255.0',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-br77')}.to raise_error(Puppet::Error, /expects a match for IP::Address::V4::NoSubnet /)
    end
  end

  context 'incorrect value: ipv6address' do
    let(:title) { 'br77' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => '1.2.3.4',
      :netmask   => '255.255.255.0',
      :ipv6address => 'notAnIP',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-br77')}.to raise_error(Puppet::Error, /(expects an IP::Address::V6 |expects a match for Variant\[IP::Address::V6::Full .*, IP::Address::V6::Compressed)/)
    end
  end

  context 'incorrect value: stp' do
    let(:title) { 'br77' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => '1.2.3.4',
      :netmask   => '255.255.255.0',
      :stp       => 'notABool',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-br77')}.to raise_error(Puppet::Error, /expects a Boolean/)
    end
  end

  context 'incorrect value: ipv6init' do
    let(:title) { 'br77' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => '1.2.3.4',
      :netmask   => '255.255.255.0',
      :ipv6init  => 'notABool',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-br77')}.to raise_error(Puppet::Error, /expects a Boolean/)
    end
  end

  context 'required parameters' do
    let(:title) { 'br1' }
    let :params do {
      :ensure    => 'up',
#      :ipaddress => '1.2.3.4',
#      :netmask   => '255.255.255.0',
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
        'BOOTPROTO=static',
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
      :ensure    => 'up',
      :ipaddress => '1.2.3.4',
      :netmask   => '255.255.255.0',
      :restart   => false,
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
        'BOOTPROTO=static',
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
      :ipaddress     => '1.2.3.4',
      :netmask       => '255.255.255.0',
      :gateway       => '1.2.3.1',
      :ipv6init      => true,
      :ipv6address   => '123:4567:89ab:cdef:123:4567:89ab:cdef/64',
      :ipv6gateway   => '123:4567:89ab:cdef:123:4567:89ab:1',
      :ipv6peerdns   => true,
      :userctl       => true,
      :peerdns       => true,
      :dns1          => '3.4.5.6',
      :dns2          => '5.6.7.8',
      :domain        => 'somedomain.com',
      :stp           => true,
      :delay         => '1000',
      :bridging_opts => 'hello_time=200 priority=65535',
      :scope         => 'peer 1.2.3.1',
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
        'BOOTPROTO=static',
        'ONBOOT=no',
        'TYPE=Bridge',
        'IPADDR=1.2.3.4',
        'NETMASK=255.255.255.0',
        'GATEWAY=1.2.3.1',
        'IPV6INIT=yes',
        'IPV6ADDR=123:4567:89ab:cdef:123:4567:89ab:cdef/64',
        'IPV6_DEFAULTGW=123:4567:89ab:cdef:123:4567:89ab:1',
        'IPV6_PEERDNS=yes',
        'PEERDNS=yes',
        'DNS1=3.4.5.6',
        'DNS2=5.6.7.8',
        'DOMAIN="somedomain.com"',
        'DELAY=1000',
        'STP=yes',
        'BRIDGING_OPTS="hello_time=200 priority=65535"',
        'SCOPE="peer 1.2.3.1"',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
    it { should contain_package('bridge-utils') }
  end

end
