# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

describe 'metricbeat' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('metricbeat::install') }
      it { is_expected.to contain_class('metricbeat::config') }
      it { is_expected.to contain_class('metricbeat::modules') }
      it { is_expected.to contain_class('metricbeat::repo') }
      it { is_expected.to contain_class('metricbeat::service') }

      describe 'metricbeat::config' do
        if os_facts[:kernel] == 'windows'
          it do
            expect(subject).to contain_file('metricbeat.yml').with(
              ensure: 'present',
              path: 'C:\\Program Files\\Metricbeat/metricbeat.yml'
            )
          end
        else
          it do
            expect(subject).to contain_file('metricbeat.yml').with(
              ensure: 'present',
              owner: 'root',
              group: 'root',
              mode: '0644',
              path: '/etc/metricbeat/metricbeat.yml',
              content: %r{name: myhost},
              validate_cmd: '/usr/share/metricbeat/bin/metricbeat -c /etc/metricbeat/metricbeat.yml test config'
            )
          end
        end

        describe 'with ensure = absent' do
          let(:params) { { 'ensure' => 'absent' } }

          if os_facts[:kernel] == 'windows'
            it do
              expect(subject).to contain_file('metricbeat.yml').with(
                ensure: 'absent',
                path: 'C:\\Program Files\\Metricbeat/metricbeat.yml'
              )
            end
          else
            it do
              expect(subject).to contain_file('metricbeat.yml').with(
                ensure: 'absent',
                path: '/etc/metricbeat/metricbeat.yml',
                validate_cmd: '/usr/share/metricbeat/bin/metricbeat -c /etc/metricbeat/metricbeat.yml test config'
              )
            end
          end
        end

        describe 'with disable_configtest = true' do
          let(:params) { { 'disable_configtest' => true } }

          if os_facts[:kernel] == 'windows'
            it do
              expect(subject).to contain_file('metricbeat.yml').with(
                ensure: 'present',
                path: 'C:\\Program Files\\Metricbeat/metricbeat.yml',
                validate_cmd: nil
              )
            end
          else
            it do
              expect(subject).to contain_file('metricbeat.yml').with(
                ensure: 'present',
                owner: 'root',
                group: 'root',
                mode: '0644',
                path: '/etc/metricbeat/metricbeat.yml',
                validate_cmd: nil
              )
            end
          end
        end

        describe 'with config_mode = 0600' do
          let(:params) { { 'config_mode' => '0600' } }

          if os_facts[:kernel] != 'windows'
            it do
              expect(subject).to contain_file('metricbeat.yml').with(
                ensure: 'present',
                owner: 'root',
                group: 'root',
                mode: '0600',
                path: '/etc/metricbeat/metricbeat.yml',
                validate_cmd: '/usr/share/metricbeat/bin/metricbeat -c /etc/metricbeat/metricbeat.yml test config'
              )
            end
          end
        end

        describe 'with major_version = 6 for new config test flag' do
          let(:params) { { 'major_version' => '6' } }

          if os_facts[:kernel] == 'windows'
            it do
              expect(subject).to contain_file('metricbeat.yml').with(
                ensure: 'present',
                path: 'C:\\Program Files\\Metricbeat/metricbeat.yml'
              )
            end
          else
            it do
              expect(subject).to contain_file('metricbeat.yml').with(
                ensure: 'present',
                owner: 'root',
                group: 'root',
                mode: '0644',
                path: '/etc/metricbeat/metricbeat.yml',
                validate_cmd: '/usr/share/metricbeat/bin/metricbeat -c /etc/metricbeat/metricbeat.yml test config'
              )
            end
          end
        end
      end

      describe 'metricbeat::install' do
        if os_facts[:kernel] == 'windows'
          it do
            expect(subject).to contain_archive('C:/Windows/Temp/metricbeat-7.9.3-windows-x86_64.zip').with(
              creates: 'C:/Program Files/Metricbeat/metricbeat-7.9.3-windows-x86_64',
              source: 'https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.9.3-windows-x86_64.zip'
            )
            expect(subject).to contain_exec('unzip metricbeat-7.9.3-windows-x86_64').with(
              command: "\$sh=New-Object -COM Shell.Application;\$sh.namespace((Convert-Path 'C:/Program Files')).Copyhere(\$sh.namespace((Convert-Path 'C:/Windows/Temp/metricbeat-7.9.3-windows-x86_64.zip')).items(), 16)", # rubocop:disable Layout/LineLength
              creates: 'C:/Program Files/Metricbeat/metricbeat-7.9.3-windows-x86_64'
            )
            expect(subject).to contain_exec('stop service metricbeat-7.9.3-windows-x86_64').with(
              creates: 'C:/Program Files/Metricbeat/metricbeat-7.9.3-windows-x86_64',
              command: 'Set-Service -Name metricbeat -Status Stopped',
              onlyif: 'if(Get-WmiObject -Class Win32_Service -Filter "Name=\'metricbeat\'") {exit 0} else {exit 1}'
            )
            expect(subject).to contain_exec('rename metricbeat-7.9.3-windows-x86_64').with(
              creates: 'C:/Program Files/Metricbeat/metricbeat-7.9.3-windows-x86_64',
              command: "Remove-Item 'C:/Program Files/Metricbeat' -Recurse -Force -ErrorAction SilentlyContinue;Rename-Item 'C:/Program Files/metricbeat-7.9.3-windows-x86_64' 'C:/Program Files/Metricbeat'" # rubocop:disable Layout/LineLength
            )
            expect(subject).to contain_exec('mark metricbeat-7.9.3-windows-x86_64').with(
              creates: 'C:/Program Files/Metricbeat/metricbeat-7.9.3-windows-x86_64',
              command: "New-Item 'C:/Program Files/Metricbeat/metricbeat-7.9.3-windows-x86_64' -ItemType file"
            )
            expect(subject).to contain_exec('install metricbeat-7.9.3-windows-x86_64').with(
              command: './install-service-metricbeat.ps1',
              cwd: 'C:/Program Files/Metricbeat',
              refreshonly: true
            )
          end
        else
          it { is_expected.to contain_package('metricbeat').with(ensure: 'present') }
        end

        describe 'with ensure = absent' do
          let(:params) { { 'ensure' => 'absent' } }

          if os_facts[:kernel] != 'windows'
            it { is_expected.to contain_package('metricbeat').with(ensure: 'absent') }
          end
        end

        describe 'with package_ensure to a specific version' do
          let(:params) { { 'package_ensure' => '7.9.3' } }

          if os_facts[:kernel] != 'windows'
            it { is_expected.to contain_package('metricbeat').with(ensure: '7.9.3') }
          end
        end

        describe 'with package_ensure = latest' do
          let(:params) { { 'package_ensure' => 'latest' } }

          if os_facts[:kernel] != 'windows'
            it { is_expected.to contain_package('metricbeat').with(ensure: 'latest') }
          end
        end
      end

      describe 'metricbeat::service' do
        it do
          expect(subject).to contain_service('metricbeat').with(
            ensure: 'running',
            enable: true
          )
        end

        describe 'with ensure = absent' do
          let(:params) { { 'ensure' => 'absent' } }

          it do
            expect(subject).to contain_service('metricbeat').with(
              ensure: 'stopped',
              enable: false
            )
          end
        end

        describe 'with service_ensure = disabled' do
          let(:params) { { 'service_ensure' => 'disabled' } }

          it do
            expect(subject).to contain_service('metricbeat').with(
              ensure: 'stopped',
              enable: false
            )
          end
        end

        describe 'with service_ensure = running' do
          let(:params) { { 'service_ensure' => 'running' } }

          it do
            expect(subject).to contain_service('metricbeat').with(
              ensure: 'running',
              enable: false
            )
          end
        end

        describe 'with service_ensure = unmanaged' do
          let(:params) { { 'service_ensure' => 'unmanaged' } }

          it do
            expect(subject).to contain_service('metricbeat').with(
              ensure: nil,
              enable: false
            )
          end
        end
      end

      context 'with elasticsearch output' do
        let(:params) do
          {
            'outputs' => { 'elasticsearch' => { 'hosts' => ['http://localhost:9200'] } }
          }
        end

        it { is_expected.to compile }

        it {
          expect(subject).to contain_file('metricbeat.yml').with(
            content: %r{output:\n\s{2}elasticsearch:\n\s{4}hosts:\n\s{4}- http://localhost:9200}
          )
        }

        it { is_expected.to contain_class('metricbeat::config') }
        it { is_expected.to contain_class('metricbeat::install').that_comes_before('Class[metricbeat::config]').that_notifies('Class[metricbeat::service]') }
        it { is_expected.to contain_class('metricbeat::repo').that_comes_before('Class[metricbeat::install]') }
        it { is_expected.to contain_class('metricbeat::service') }
      end

      context 'with manage_repo = false' do
        let(:params) do
          {
            'manage_repo' => false
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('metricbeat::config') }
        it { is_expected.to contain_class('metricbeat::install').that_comes_before('Class[metricbeat::config]').that_notifies('Class[metricbeat::service]') }
        it { is_expected.not_to contain_class('metricbeat::repo') }
        it { is_expected.to contain_class('metricbeat::service') }
      end

      context 'with ensure = absent' do
        let(:params) do
          {
            'ensure' => 'absent'
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('metricbeat::config') }
        it { is_expected.to contain_class('metricbeat::install') }
        it { is_expected.to contain_class('metricbeat::repo').that_comes_before('Class[metricbeat::install]') }
        it { is_expected.to contain_class('metricbeat::service').that_comes_before('Class[metricbeat::install]') }
      end

      context 'with ensure = idontknow' do
        let(:params) { { 'ensure' => 'idontknow' } }

        it { is_expected.to raise_error(Puppet::Error) }
      end

      context 'with service_ensure = thisisnew' do
        let(:params) { { 'ensure' => 'thisisnew' } }

        it { is_expected.to raise_error(Puppet::Error) }
      end

      context 'with multiple processors' do
        let(:params) do
          {
            'processors' => [
              { 'add_cloud_metadata' => { 'timeout' => '3s' } },
              { 'drop_fields' => { 'fields' => ['field1', 'field2'] } },
            ]
          }
        end

        it {
          expect(subject).to contain_file('metricbeat.yml').with(
            content: %r{processors:\n- add_cloud_metadata:\n\s{4}timeout: 3s\n- drop_fields:\n\s{4}fields:\n\s{4}- field1\n\s{4}- field2}
          )
        }
      end
    end
  end
end
