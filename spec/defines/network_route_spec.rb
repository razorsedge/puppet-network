#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::route', :type => 'define' do

  context 'singular parameters' do
    let(:title) { 'eth1' }
    let :params do {
      :ipaddress => [ '192.168.2.1', ],
      :netmask   => [ '255.255.255.1', ],
      :gateway   => [ '192.168.1.2', ],
    }
    end
    let(:facts) {{ :osfamily => 'RedHat' }}
    it { should contain_file('route-eth1').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/route-eth1'
    )}
    it 'should contain File[route-eth1] with contents "ADDRESS0=192.168.2.1\nNETMASK0=255.255.255.1\nGATEWAY0=192.168.1.2"' do
      verify_contents(catalogue, 'route-eth1', [
        'ADDRESS0=192.168.2.1',
        'NETMASK0=255.255.255.1',
        'GATEWAY0=192.168.1.2',
      ])
    end
    it { should contain_service('network') }
  end

  context 'array parameters' do
    let(:title) { 'eth2' }
    let :params do {
      :ipaddress => [ '192.168.2.0', '10.0.0.0', ],
      :netmask   => [ '255.255.255.0', '255.0.0.0', ],
      :gateway   => [ '192.168.1.1', '10.0.0.1', ]
    }
    end
    let(:facts) {{ :osfamily => 'RedHat' }}
    it { should contain_file('route-eth2').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/route-eth2'
    )}
    it 'should contain File[route-eth2] with contents "ADDRESS0=192.168.2.0\nADDRESS1=10.0.0.0\nNETMASK0=255.255.255.0\nNETMASK1=255.0.0.0\nGATEWAY0=192.168.1.1\nGATEWAY1=10.0.0.1"' do
      verify_contents(catalogue, 'route-eth2', [
        'ADDRESS0=192.168.2.0',
        'ADDRESS1=10.0.0.0',
        'NETMASK0=255.255.255.0',
        'NETMASK1=255.0.0.0',
        'GATEWAY0=192.168.1.1',
        'GATEWAY1=10.0.0.1',
      ])
    end
    it { should contain_service('network') }
  end

end
