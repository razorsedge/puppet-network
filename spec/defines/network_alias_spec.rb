#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::alias', :type => 'define' do

  context 'incorrect value: ensure' do
    let(:title) { 'eth1:1' }
    let :params do {
      :ensure    => 'blah',
      :ipaddress => '1.2.3.4',
      :netmask   => '255.255.255.0',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-eth1:1')}.to raise_error(Puppet::Error, /\$ensure must be either "up" or "down"./)
    end
  end

  context 'incorrect value: ipaddress' do
    let(:title) { 'eth1:1' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => 'notAnIP',
      :netmask   => '255.255.255.0',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-eth1:1')}.to raise_error(Puppet::Error, /notAnIP is not an IP address./)
    end
  end

  context 'required parameters' do
    let(:title) { 'bond2:1' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => '1.2.3.6',
      :netmask   => '255.255.255.0',
    }
    end
    let(:facts) {{ :osfamily => 'RedHat' }}
    it { should contain_file('ifcfg-bond2:1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-bond2:1',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-bond2:1] with required contents' do
      verify_contents(catalogue, 'ifcfg-bond2:1', [
        'DEVICE=bond2:1',
        'BOOTPROTO=none',
        'ONPARENT=yes',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.6',
        'NETMASK=255.255.255.0',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

  context 'optional parameters' do
    let(:title) { 'bond3:2' }
    let :params do {
      :ensure    => 'down',
      :ipaddress => '33.2.3.127',
      :netmask   => '255.255.0.0',
      :gateway   => '33.2.3.1',
      :userctl   => true,
    }
    end
    let(:facts) {{ :osfamily => 'RedHat' }}
    it { should contain_file('ifcfg-bond3:2').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-bond3:2',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-bond3:2] with required contents' do
      verify_contents(catalogue, 'ifcfg-bond3:2', [
        'DEVICE=bond3:2',
        'BOOTPROTO=none',
        'ONPARENT=no',
        'TYPE=Ethernet',
        'IPADDR=33.2.3.127',
        'NETMASK=255.255.0.0',
        'GATEWAY=33.2.3.1',
        'USERCTL=yes',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

end
