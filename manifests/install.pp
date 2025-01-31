# metricbeat::install
# @api private
#
# Manages the state of Package['metricbeat']
#
# @summary Manages the state of Package['metricbeat']
class metricbeat::install (
  String $ensure     = $metricbeat::ensure,
) {
  # The base class must be included first because parameter defaults depend on it
  if ! defined(Class['metricbeat']) {
    fail('You must include the metricbeat class before using any metricbeat defined resources')
  }
  if $facts['kernel'] == 'windows' {
    $filename       = regsubst($metricbeat::download_url, '^https?.*\/([^\/]+)\.[^.].*', '\1')
    $foldername     = 'Metricbeat'
    $zip_file       = join([$metricbeat::tmp_dir, "${filename}.zip"], '/')
    $install_folder = join([$metricbeat::install_dir, $foldername], '/')
    $version_file   = join([$install_folder, $filename], '/')

    Exec {
      provider => powershell,
    }

    if !defined(File[$metricbeat::install_dir]) {
      file { $metricbeat::install_dir:
        ensure => directory,
      }
    }

    archive { $zip_file:
      source       => $metricbeat::download_url,
      cleanup      => false,
      creates      => $version_file,
      proxy_server => $metricbeat::proxy_address,
    }
    if $facts['powershell_version'] =~ '5' {
      $unzip_command = "Expand-Archive ${zip_file} \"${metricbeat::install_dir}\""
    }
    else {
      $unzip_command = "\$sh=New-Object -COM Shell.Application;\$sh.namespace((Convert-Path '${metricbeat::install_dir}')).Copyhere(\$sh.namespace((Convert-Path '${zip_file}')).items(), 16)" # lint:ignore:140chars
    }

    exec { "unzip ${filename}":
      command => $unzip_command,
      creates => $version_file,
      require => [
        File[$metricbeat::install_dir],
        Archive[$zip_file],
      ],
    }

    # Clean up after ourselves
    file { $zip_file:
      ensure  => absent,
      backup  => false,
      require => Exec["unzip ${filename}"],
    }

    # You can't remove the old dir while the service has files locked...
    exec { "stop service ${filename}":
      command => 'Set-Service -Name metricbeat -Status Stopped',
      creates => $version_file,
      onlyif  => 'if(Get-WmiObject -Class Win32_Service -Filter "Name=\'metricbeat\'") {exit 0} else {exit 1}',
      require => Exec["unzip ${filename}"],
    }
    exec { "rename ${filename}":
      command => "Remove-Item '${install_folder}' -Recurse -Force -ErrorAction SilentlyContinue;Rename-Item '${metricbeat::install_dir}/${filename}' '${install_folder}'", # lint:ignore:140chars
      creates => $version_file,
      require => Exec["stop service ${filename}"],
    }
    exec { "mark ${filename}":
      command => "New-Item '${version_file}' -ItemType file",
      creates => $version_file,
      require => Exec["rename ${filename}"],
    }
    exec { "install ${filename}":
      cwd         => $install_folder,
      command     => './install-service-metricbeat.ps1',
      refreshonly => true,
      subscribe   => Exec["mark ${filename}"],
    }
  }
  else {
    if $metricbeat::ensure == 'present' {
      $package_ensure = $metricbeat::package_ensure
    }
    else {
      $package_ensure = $metricbeat::ensure
    }

    package { 'metricbeat':
      ensure => $package_ensure,
    }
  }
}
