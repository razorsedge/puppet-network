#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::global', :type => 'class' do

  context 'default parameters' do
    let(:params) {{}}
    it { should contain_file('network.sysconfig').with_ensure('present') }
    it { should contain_service('network').with_ensure('running') }
  end

end
