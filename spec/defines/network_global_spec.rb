#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::global', :type => 'define' do

  context 'default parameters' do
    let(:title) { 'default' }
    let(:params) {{}}
    it { should contain_file('network.sysconfig').with_ensure('present') }
    it { should contain_service('network').with_ensure('running') }
  end

end
