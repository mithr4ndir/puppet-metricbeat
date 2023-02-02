# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

describe 'metricbeat::modules' do
  let :pre_condition do
    [ 'include metricbeat' ]
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'nginx' }

      context 'with modules => nginx' do
        let(:params) do
          { 'modules' => { 'nginx' => 'enabled' } }
        end

        it { is_expected.to contain_exec('enable nginx') }
      end
    end
  end
end
