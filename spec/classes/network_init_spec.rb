#!/usr/bin/env rspec

require 'spec_helper'

describe 'network', :type => 'class' do

  context 'on a non-supported operatingsystem' do
    let(:facts) {{ :osfamily => 'foo' }}

    it 'should fail' do
      expect {
        should raise_error(Puppet::Error, /This network module only supports RedHat-based systems./)
      }
    end
  end

  context 'on a supported operatingsystem' do
    let(:facts) {{
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7.0',
    }}

    it { is_expected.to compile.with_all_deps }
  end

end
