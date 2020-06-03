#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::route', :type => 'define' do

  context 'singular parameters' do
    let(:pre_condition) { "file { 'ifcfg-eth1': }" }
    let(:title) { 'eth1' }
    let :params do {
      :ipaddress => [ '192.168.2.1', ],
      :netmask   => [ '255.255.255.1', ],
      :gateway   => [ '192.168.1.2', ],
    }
    end
    let(:facts) {{
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7.0',
    }}
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
    it { is_expected.to contain_file('route-eth1').that_notifies('Class[Network::Service]') }
  end

  context 'singular parameters, restart => false' do
    let(:pre_condition) { "file { 'ifcfg-eth1': }" }
    let(:title) { 'eth1' }
    let :params do {
      :ipaddress => [ '192.168.2.1', ],
      :netmask   => [ '255.255.255.1', ],
      :gateway   => [ '192.168.1.2', ],
      :restart   => false,
    }
    end
    let(:facts) {{
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7.0',
    }}
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
    it { is_expected.to_not contain_file('route-eth1').that_notifies('Class[Network::Service]') }
  end

  context 'array parameters' do
    let(:pre_condition) { "file { 'ifcfg-eth2': }" }
    let(:title) { 'eth2' }
    let :params do {
      :ipaddress => [ '192.168.2.0', '10.0.0.0', ],
      :netmask   => [ '255.255.255.0', '255.0.0.0', ],
      :gateway   => [ '192.168.1.1', '10.0.0.1', ]
    }
    end
    let(:facts) {{
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7.0',
    }}
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

  context 'new parameters v4' do
    let(:pre_condition) {'network::if{"eth0": ensure => "up"}'}
    let(:title) { 'eth0' }
    let :params do {
      :ipv4_routes => [
        {
          'dest'    => '192.168.254.0/24',
          'gateway' => '192.168.18.1',
        },{
          'dest'    => '192.168.253.0/24',
          'table'   => '1',
        },{
          'dest'    => '192.168.252.0/24',
          'gateway' => '192.168.18.15',
          'table'   => '2',
        },
      ]
    }
    end
    let(:facts) {{
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7.0',
    }}
    it { should contain_file('route-eth0').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/route-eth0'
    )}
    it 'should contain File[route-eth0] with contents "192.168.254.0/24 via 192.168.18.1 dev eth0\n192.168.253.0/24 dev eth0 table 1\n192.168.252.0/24 via 192.168.18.15 dev eth0 table 1"' do
      verify_contents(catalogue, 'route-eth0', [
        '192.168.254.0/24 via 192.168.18.1 dev eth0',
        '192.168.253.0/24 dev eth0 table 1',
        '192.168.252.0/24 via 192.168.18.15 dev eth0 table 2',
      ])
    end
    it { should contain_service('network') }
  end

  context 'new parameters v6' do
    let(:pre_condition) {'network::if{"eth0": ensure => "up"}'}
    let(:title) { 'eth0' }
    let :params do {
      :ipv6_routes => [
        {
          'dest'    => '0:0:0:0:0:ffff:c0a8:fe00/120',
          'gateway' => '0:0:0:0:0:ffff:c0a8:1201',
        },{
          'dest'    => '0:0:0:0:0:ffff:c0a8:fd00/120',
          'table'   => '1',
        },{
          'dest'    => '0:0:0:0:0:ffff:c0a8:fc00/120',
          'gateway' => '0:0:0:0:0:ffff:c0a8:120f',
          'table'   => '2',
        },
      ]
    }
    end
    let(:facts) {{
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7.0',
    }}
    it { should contain_file('route6-eth0').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/route6-eth0'
    )}
    it 'should contain File[route6-eth0] with contents "0:0:0:0:0:ffff:c0a8:fe00/120 via 0:0:0:0:0:ffff:c0a8:1201 dev eth0\n0:0:0:0:0:ffff:c0a8:fd00/120 dev eth0 table 1\n0:0:0:0:0:ffff:c0a8:fc00/120 via 0:0:0:0:0:ffff:c0a8:120f dev eth0 table 2"' do
      verify_contents(catalogue, 'route6-eth0', [
        '0:0:0:0:0:ffff:c0a8:fe00/120 via 0:0:0:0:0:ffff:c0a8:1201 dev eth0',
        '0:0:0:0:0:ffff:c0a8:fd00/120 dev eth0 table 1',
        '0:0:0:0:0:ffff:c0a8:fc00/120 via 0:0:0:0:0:ffff:c0a8:120f dev eth0 table 2',
      ])
    end
    it { should contain_service('network') }
  end

end
