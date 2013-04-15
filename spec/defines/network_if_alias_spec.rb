#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::if::alias', :type => 'define' do

  context 'incorrect value: ipaddress' do
    let(:title) { 'eth77' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => 'notAnIP',
      :netmask   => '255.255.255.0',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-eth77')}.to raise_error(Puppet::Error, /notAnIP is not an IP address./)
    end
  end

  context 'required parameters' do
    let(:title) { 'eth99:1' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => '1.2.3.99',
      :netmask   => '255.255.255.0',
    }
    end
    let(:facts) {{ :osfamily => 'RedHat' }}
    it { should contain_file('ifcfg-eth99:1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth99:1',
      :notify => 'Service[network]'
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
    it { should contain_service('network') }
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
    let(:facts) {{ :osfamily => 'RedHat' }}
    it { should contain_file('ifcfg-eth8:2').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth8:2',
      :notify => 'Service[network]'
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
    it { should contain_service('network') }
  end

end
