#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::if::alias', :type => 'define' do

  context 'required parameters' do
    let(:title) { 'eth99:1' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => '1.2.3.99',
      :netmask   => '255.255.255.0',
    }
    end
    it { should contain_file('ifcfg-eth99:1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth99:1'
    )}
    it 'should contain File[ifcfg-eth99:1] with required contents' do
      verify_contents(subject, 'ifcfg-eth99:1', [
        'DEVICE=eth99:1',
        'BOOTPROTO=none',
        'ONPARENT=yes',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.99',
        'NETMASK=255.255.255.0',
        'PEERDNS=no',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_exec('ifup-eth99:1').with(
      :command     => '/sbin/ifdown eth99:1; /sbin/ifup eth99:1',
      :refreshonly => true
    )}
  end

  context 'optional parameters' do
    let(:title) { 'eth8:2' }
    let :params do {
      :ensure    => 'down',
      :ipaddress => '33.2.3.8',
      :netmask   => '255.255.0.0',
      :gateway   => '33.2.3.255',
      :peerdns   => true,
      :dns1      => '2.3.4.5',
      :dns2      => '5.6.7.8',
      :domain    => 'somedomain.com',
    }
    end
    it { should contain_file('ifcfg-eth8:2').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth8:2'
    )}
    it 'should contain File[ifcfg-eth8:2] with required contents' do
      verify_contents(subject, 'ifcfg-eth8:2', [
        'DEVICE=eth8:2',
        'BOOTPROTO=none',
        'ONPARENT=no',
        'TYPE=Ethernet',
        'IPADDR=33.2.3.8',
        'NETMASK=255.255.0.0',
        'GATEWAY=33.2.3.255',
        'PEERDNS=yes',
        'DNS1=2.3.4.5',
        'DNS2=5.6.7.8',
        'DOMAIN="somedomain.com"',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_exec('ifdown-eth8:2').with(
      :command     => '/sbin/ifdown eth8:2',
      :refreshonly => true
    )}
  end

end
