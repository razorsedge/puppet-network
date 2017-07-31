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
      :osfamily               => 'RedHat',
      :operatingsystem        => 'RedHat',
      :operatingsystemrelease => '7.0',
      :fqdn                   => 'localhost.localdomain',
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
        'RES_OPTIONS="single-request-reopen"',
      ])
    end
    it { should_not contain_exec('hostnamectl set-hostname') }
    it { is_expected.to contain_file('network.sysconfig').that_notifies('Service[network]') }
  end

  context 'on a supported operatingsystem, default parameters, restart => false' do
    let(:params) {{
      :restart => false
    }}
    let :facts do {
      :osfamily               => 'RedHat',
      :operatingsystem        => 'RedHat',
      :operatingsystemrelease => '7.0',
      :fqdn                   => 'localhost.localdomain',
    }
    end
    it { should contain_class('network') }
    it { should contain_file('network.sysconfig').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network'
    )}
    it 'should contain File[network.sysconfig] with correct contents' do
      verify_contents(catalogue, 'network.sysconfig', [
        'NETWORKING=yes',
        'NETWORKING_IPV6=no',
        'HOSTNAME=localhost.localdomain',
      ])
    end
    it { should_not contain_exec('hostnamectl set-hostname') }
    it { is_expected.to_not contain_file('network.sysconfig').that_notifies('Service[network]') }
  end

  context 'on a supported operatingsystem, custom parameters, systemd' do
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
      :osfamily               => 'RedHat',
      :operatingsystem        => 'RedHat',
      :operatingsystemrelease => '7.0',
      :fqdn                   => 'localhost.localdomain',
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
        'RES_OPTIONS="single-request-reopen"',
      ])
    end
    it { should contain_exec('hostnamectl set-hostname').with(
      :command => 'hostnamectl set-hostname myHostname',
      :unless  => 'hostnamectl --static | grep ^myHostname$',
      :path    => '/bin:/usr/bin'
    )}
  end

  context 'on a supported operatingsystem, custom parameters, no systemd' do
    let :params do {
      :hostname => 'myHostname',
    }
    end
    let :facts do {
      :osfamily               => 'RedHat',
      :operatingsystem        => 'RedHat',
      :operatingsystemrelease => '6.0',
      :fqdn                   => 'localhost.localdomain',
    }
    end
    it 'should contain File[network.sysconfig] with correct contents' do
      verify_contents(catalogue, 'network.sysconfig', [
        'HOSTNAME=myHostname',
      ])
    end
    it { should_not contain_exec('hostnamectl set-hostname') }
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

    context 'manage_hwaddr = foo' do
      let(:params) {{ :manage_hwaddr  => 'foo' }}

      it 'should fail' do
        expect {
          should raise_error(Puppet::Error, /$manage_hwaddr is not a boolean.  It looks to be a String./)
        }
      end
    end

  end

    context 'requestreopen = foo' do
      let(:params) {{ :requestreopen => 'foo' }}

      it 'should fail' do
        expect { 
          should raise_error(Puppet::Error, /$requestreopen is not a boolean.  It looks to be a String./)
        }
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
      :requestreopen  => false,
    }
    end
    let :facts do {
      :osfamily => 'RedHat',
      :operatingsystem        => 'RedHat',
      :operatingsystemrelease => '6.0',
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
