# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

describe 'metricbeat::custom_modules' do
  let :pre_condition do
    [ 'include metricbeat' ]
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'kafka' }

      context 'with custom_modules => kafka' do
        let(:params) do
          { 'custom_modules' => { 'kafka' => { 'host' => '127.0.0.1' } } }
        end

        it { is_expected.to contain_file('kafka.yml').with_content %r{^host: 127.0.0.1} }
      end
    end
  end
end
