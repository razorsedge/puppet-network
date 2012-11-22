#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::bond::alias', :type => 'define' do

  context 'required parameters' do
    let(:title) { 'bond2:1' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => '1.2.3.6',
      :netmask   => '255.255.255.0',
    }
    end
    it { should contain_file('ifcfg-bond2:1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-bond2:1'
    )}
    it 'should contain File[ifcfg-bond2:1] with required contents' do
      verify_contents(subject, 'ifcfg-bond2:1', [
        'DEVICE=bond2:1',
        'BOOTPROTO=none',
        'ONPARENT=yes',
        'TYPE=Ethernet',
        'IPADDR=1.2.3.6',
        'NETMASK=255.255.255.0',
        'PEERDNS=no',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_exec('ifup-bond2:1').with(
      :command     => '/sbin/ifdown bond2:1; /sbin/ifup bond2:1',
      :refreshonly => true
    )}
  end

  context 'optional parameters' do
    let(:title) { 'bond3:2' }
    let :params do {
      :ensure    => 'down',
      :ipaddress => '33.2.3.127',
      :netmask   => '255.255.0.0',
      :gateway   => '33.2.3.1',
#      :peerdns   => true,
#      :dns1      => '2.3.4.5',
#      :dns2      => '5.6.7.8',
#      :domain    => 'somedomain.com',
    }
    end
    it { should contain_file('ifcfg-bond3:2').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-bond3:2'
    )}
    it 'should contain File[ifcfg-bond3:2] with required contents' do
      verify_contents(subject, 'ifcfg-bond3:2', [
        'DEVICE=bond3:2',
        'BOOTPROTO=none',
        'ONPARENT=no',
        'TYPE=Ethernet',
        'IPADDR=33.2.3.127',
        'NETMASK=255.255.0.0',
        'GATEWAY=33.2.3.1',
        'PEERDNS=no',
#        'PEERDNS=yes',
#        'DNS1=2.3.4.5',
#        'DNS2=5.6.7.8',
#        'DOMAIN="somedomain.com"',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_exec('ifdown-bond3:2').with(
      :command     => '/sbin/ifdown bond3:2',
      :refreshonly => true
    )}
  end

end
