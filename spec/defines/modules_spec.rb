# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

describe 'metricbeat::modules' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:pre_condition) { 'include ::metricbeat' }
      let(:facts) { os_facts }

      let(:title) { 'system' }

      if os_facts[:kernel] == 'windows'
        context 'with modules = windows do'
        let(:params) { { 'modules' => { 'windows' => 'enabled' } } }
        it {
          expect(subject).to contain_exec('enable windows').with(
            command: 'C:\\Program Files\\Metricbeat\\metricbeat.exe modules enable windows'
          )
        }
      else
        context 'with system module enabled' do
          let(:params) { { 'modules' => { 'system' => 'enabled', 'nginx' => 'disabled' } } }

          it {
            expect(subject).to contain_exec('enable system').with(
              command: '/usr/share/metricbeat/bin/metricbeat modules enable system'
            )
          }
        end

        context 'with system module disabled' do
          let(:params) { { 'modules' => { 'system' => 'disabled' } } }

          it {
            expect(subject).to contain_exec('disable system').with(
              command: '/usr/share/metricbeat/bin/metricbeat modules disable system'
            )
          }
        end

        context 'with custom module configurations' do
          let(:params) { { 'custom_modules' => { 'system' => [{ 'module' => 'system', 'metricsets' => ['one', 'two'], 'period' => '10s' }] } } }

          it {
            expect(subject).to contain_file('system.yml').with(
              content: %r{- module: system}
            )
          }
        end
      end
    end
  end
end
