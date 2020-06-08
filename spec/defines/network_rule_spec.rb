#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::rule', :type => 'define' do

  context 'new ipv4' do
    let(:pre_condition) {'network::if{"eth0": ensure => "up"}'}
    let(:title) { 'eth0' }
    let :params do {
      :ipv4_rules => [
        {
          'iif'     => 'eth0',
          'table'   => '1',
        },{
          'from'    => '192.168.253.254',
          'table'   => '1',
        },{
          'from'    => '192.168.252.0/24',
          'reject'  => true,
        },
      ]
    }
    end
    let(:facts) {{ :osfamily => 'RedHat' }}
    it { should contain_file('rule-eth0').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/rule-eth0'
    )}
    it 'should contain File[rule-eth0] with contents "iif eth0 table 1 \nfrom 192.168.253.254 table 1 \nfrom 192.168.252.0/24 reject "' do
      verify_contents(catalogue, 'rule-eth0', [
        'iif eth0 table 1 ',
        'from 192.168.253.254 table 1 ',
        'from 192.168.252.0/24 reject ',
      ])
    end
    it { should contain_service('network') }
  end

  context 'new ipv6' do
    let(:pre_condition) {'network::if{"eth0": ensure => "up"}'}
    let(:title) { 'eth0' }
    let :params do {
      :ipv6_rules => [
        {
          'iif'     => 'eth0',
          'table'   => '1',
        },{
          'from'    => '0:0:0:0:0:ffff:c0a8:fdfe',
          'table'   => '1',
        },{
          'from'    => '0:0:0:0:0:ffff:c0a8:fc00/120',
          'reject'  => true,
        },
      ]
    }
    end
    let(:facts) {{ :osfamily => 'RedHat' }}
    it { should contain_file('rule6-eth0').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/rule6-eth0'
    )}
    it 'should contain File[rule6-eth0] with contents "iif eth0 table 1 \nfrom 0:0:0:0:0:ffff:c0a8:fdfe table 1 \nfrom 0:0:0:0:0:ffff:c0a8:fc00/120 reject "' do
      verify_contents(catalogue, 'rule6-eth0', [
        'iif eth0 table 1 ',
        'from 0:0:0:0:0:ffff:c0a8:fdfe table 1 ',
        'from 0:0:0:0:0:ffff:c0a8:fc00/120 reject ',
      ])
    end
    it { should contain_service('network') }
  end

end
