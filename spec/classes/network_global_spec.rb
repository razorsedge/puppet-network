#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::global', :type => 'class' do

  context 'on a non-supported operatingsystem' do
    let :facts do {
      :osfamily => 'foo',
    }
    end
    it 'should fail' do
      expect {
        should raise_error(Puppet::Error, /Unsupported platform: foo/)
      }
    end
  end

  context 'on a supported operatingsystem, default parameters' do
    let(:params) {{}}
    let :facts do {
      :osfamily => 'RedHat',
      :fqdn     => 'localhost.localdomain',
    }
    end
    it { should contain_class('network') }
    it { should contain_file('network.sysconfig').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network',
      :notify => 'Service[network]'
    )}
    it 'should contain File[network.sysconfig] with correct contents' do
      verify_contents(catalogue, 'network.sysconfig', [
        'NETWORKING=yes',
        'NETWORKING_IPV6=no',
        'HOSTNAME=localhost.localdomain',
      ])
    end
  end

  context 'on a supported operatingsystem, custom parameters' do
    let :params do {
      :hostname   => 'myHostname',
      :gateway    => '1.2.3.4',
      :gatewaydev => 'eth2',
      :nisdomain  => 'myNisDomain',
      :vlan       => 'yes',
      :nozeroconf => 'yes',
    }
    end
    let :facts do {
      :osfamily => 'RedHat',
      :fqdn     => 'localhost.localdomain',
    }
    end
    it 'should contain File[network.sysconfig] with correct contents' do
      verify_contents(catalogue, 'network.sysconfig', [
        'NETWORKING=yes',
        'NETWORKING_IPV6=no',
        'HOSTNAME=myHostname',
        'GATEWAY=1.2.3.4',
        'GATEWAYDEV=eth2',
        'NISDOMAIN=myNisDomain',
        'VLAN=yes',
        'NOZEROCONF=yes',
      ])
    end
  end

  context 'on a supported operatingsystem, bad parameters' do
    let(:facts) {{ :osfamily => 'RedHat' }}

    context 'gateway = foo' do
      let(:params) {{ :gateway => 'foo' }}

      it 'should fail' do
        expect {
          should raise_error(Puppet::Error, /$gateway is not an IP address./)
        }
      end
    end

    context 'ipv6gateway = foo' do
      let(:params) {{ :ipv6gateway => 'foo' }}

      it 'should fail' do
        expect {
          should raise_error(Puppet::Error, /$ipv6gateway is not an IPv6 address./)
        }
      end
    end

    context 'vlan = foo' do
      let(:params) {{ :vlan => 'foo' }}

      it 'should fail' do
        expect {
          should raise_error(Puppet::Error, /$vlan must be either "yes" or "no"./)
        }
      end
    end

    context 'ipv6networking = foo' do
      let(:params) {{ :ipv6networking => 'foo' }}

      it 'should fail' do
        expect { 
          should raise_error(Puppet::Error, /$ipv6networking is not a boolean.  It looks to be a String./)
        }
      end
    end

  end

  context 'on a supported operatingsystem, custom parameters' do
    let :params do {
      :hostname       => 'myHostname',
      :gateway        => '1.2.3.4',
      :gatewaydev     => 'eth2',
      :nisdomain      => 'myNisDomain',
      :vlan           => 'yes',
      :nozeroconf     => 'yes',
      :ipv6networking => true,
      :ipv6gateway    => '123:4567:89ab:cdef:123:4567:89ab:1',
      :ipv6defaultdev => 'eth3',
    }
    end
    let :facts do {
      :osfamily => 'RedHat',
      :fqdn     => 'localhost.localdomain',
    }
    end
    it 'should contain File[network.sysconfig] with correct contents' do
      verify_contents(catalogue, 'network.sysconfig', [
        'NETWORKING=yes',
        'NETWORKING_IPV6=yes',
        'IPV6_DEFAULTGW=123:4567:89ab:cdef:123:4567:89ab:1',
        'IPV6_DEFAULTDEV=eth3',
        'HOSTNAME=myHostname',
        'GATEWAY=1.2.3.4',
        'GATEWAYDEV=eth2',
        'NISDOMAIN=myNisDomain',
        'VLAN=yes',
        'NOZEROCONF=yes',
      ])
    end
  end
end
