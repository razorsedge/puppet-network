#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::alias::range', :type => 'define' do

  context 'incorrect value: ensure' do
    let(:title) { 'bond77' }
    let :params do {
      :ensure          => 'notCorrect',
      :ipaddress_start => '1.2.3.4',
      :ipaddress_end   => '1.2.3.4',
      :clonenum_start  => '0',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-bond77-range0')}.to raise_error(Puppet::Error, /\$ensure must be either "up", "down", or "absent"./)
    end
  end

  context 'incorrect value: ipaddress_start' do
    let(:title) { 'bond77' }
    let :params do {
      :ensure          => 'up',
      :ipaddress_start => 'notAnIP',
      :ipaddress_end   => '1.2.3.4',
      :clonenum_start  => '0',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-bond77-range0')}.to raise_error(Puppet::Error, /notAnIP is not an IP address./)
    end
  end

  context 'incorrect value: ipaddress_end' do
    let(:title) { 'bond77' }
    let :params do {
      :ensure          => 'up',
      :ipaddress_start => '1.2.3.4',
      :ipaddress_end   => 'notAnIP',
      :clonenum_start  => '0',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-bond77-range0')}.to raise_error(Puppet::Error, /notAnIP is not an IP address./)
    end
  end


  context 'required parameters: ensure => up' do
    let(:title) { 'eth99' }
    let :params do {
      :ensure          => 'up',
      :ipaddress_start => '1.2.3.99',
      :ipaddress_end   => '1.2.3.200',
      :clonenum_start  => '3',
    }
    end
    let(:facts) {{ :osfamily => 'RedHat' }}
    it { should contain_file('ifcfg-eth99-range3').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth99-range3',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-eth99-range3] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth99-range3', [
        'IPADDR_START=1.2.3.99',
        'IPADDR_END=1.2.3.200',
        'CLONENUM_START=3',
        'NO_ALIASROUTING=no',
        'ONPARENT=yes',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
    it { is_expected.to contain_file('ifcfg-eth99-range3').that_notifies('Service[network]') }
  end

  context 'required parameters: ensure => up, restart => false' do
    let(:title) { 'eth99' }
    let :params do {
      :ensure          => 'up',
      :ipaddress_start => '1.2.3.99',
      :ipaddress_end   => '1.2.3.200',
      :clonenum_start  => '3',
      :restart         => false,
    }
    end
    let(:facts) {{ :osfamily => 'RedHat' }}
    it { should contain_file('ifcfg-eth99-range3').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth99-range3'
    )}
    it 'should contain File[ifcfg-eth99-range3] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth99-range3', [
        'IPADDR_START=1.2.3.99',
        'IPADDR_END=1.2.3.200',
        'CLONENUM_START=3',
        'NO_ALIASROUTING=no',
        'ONPARENT=yes',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
    it { is_expected.to_not contain_file('ifcfg-eth99-range3').that_notifies('Service[network]') }
  end

  context 'required parameters: ensure => down' do
    let(:title) { 'bond7' }
    let :params do {
      :ensure          => 'down',
      :ipaddress_start => '1.2.3.3',
      :ipaddress_end   => '1.2.3.4',
      :clonenum_start  => '9',
      :noaliasrouting  => true,
    }
    end
    let(:facts) {{ :osfamily => 'RedHat' }}
    it { should contain_file('ifcfg-bond7-range9').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-bond7-range9',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-bond7-range9] with required contents' do
      verify_contents(catalogue, 'ifcfg-bond7-range9', [
        'IPADDR_START=1.2.3.3',
        'IPADDR_END=1.2.3.4',
        'CLONENUM_START=9',
        'NO_ALIASROUTING=yes',
        'ONPARENT=no',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

  context 'required parameters: ensure => absent' do
    let(:title) { 'bond6' }
    let :params do {
      :ensure          => 'absent',
      :ipaddress_start => '1.2.3.3',
      :ipaddress_end   => '1.2.3.4',
      :clonenum_start  => '9',
    }
    end
    let(:facts) {{ :osfamily => 'RedHat' }}
    it { should contain_file('ifcfg-bond6-range9').with(
      :ensure => 'absent',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-bond6-range9',
      :notify => 'Service[network]'
    )}
    it { should contain_service('network') }
  end

  context 'optional parameters' do
    let(:title) { 'eth8' }
    let :params do {
      :ensure          => 'up',
      :ipaddress_start => '1.2.3.3',
      :ipaddress_end   => '1.2.3.4',
      :clonenum_start  => '9',
      :noaliasrouting  => true,
      :netmask         => '255.255.255.0',
      :broadcast       => '1.2.3.0',
      :arpcheck        => false,
    }
    end
    let(:facts) {{ :osfamily => 'RedHat' }}
    it { should contain_file('ifcfg-eth8-range9').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-eth8-range9',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-eth8-range9] with required contents' do
      verify_contents(catalogue, 'ifcfg-eth8-range9', [
        'IPADDR_START=1.2.3.3',
        'IPADDR_END=1.2.3.4',
        'CLONENUM_START=9',
        'NO_ALIASROUTING=yes',
        'NETMASK=255.255.255.0',
        'BROADCAST=1.2.3.0',
        'ARPCHECK=no',
        'ONPARENT=yes',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
  end

end
