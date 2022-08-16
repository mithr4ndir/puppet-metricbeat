# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include metricbeat::modules
# @param modules Modules to enable or disable
define metricbeat::modules (
  Optional[Hash] $custom_modules = $metricbeat::custom_modules,
  Optional[Hash] $modules = $metricbeat::modules,
) {
  if $facts['os']['family'] == 'windows' {
    $cmd = 'cmd.exe /c metricbeat.exe'
  } else {
    $cmd = $metricbeat::metricbeat_path
  }
  if $modules {
    $modules.each | $module | {
      if $module[1] == 'disabled' {
        $status = 'disable'
        $extension = '.disabled'
      } else {
        $status = 'enable'
        $extension = undef
      }
      if ! defined(Exec["${status} ${module[0]}"]) {
        exec { "${status} ${module[0]}":
          command => "${cmd} modules ${status} ${module[0]}",
          path    => $facts['path'],
          cwd     => $metricbeat::config_dir,
          creates => "${metricbeat::config_dir}/modules.d/${module[0]}.yml${extension}",
          notify  => Class['Metricbeat::Service']
        }
      }
    }
  }
  if $custom_modules {
    $custom_modules.each | $custom | {
      # ensure period is defined for entry entry as it is required.
      $config = $custom[1].map | $h | { $h['period'] }
      $conf2 = ($config.filter |$x| {$x != undef}).length
      $value1 = $config.length
      if $value1 != $conf2 {
        fail('You must include the period to collect metricsets')
      } else {
        file { "${custom[0]}.yml":
          ensure  => $metricbeat::ensure,
          path    => "${metricbeat::config_dir}/modules.d/${custom[0]}.yml",
          owner   => $metricbeat::owner,
          group   => $metricbeat::group,
          mode    => $metricbeat::config_mode,
          content => inline_template('<%= @custom[1].to_yaml() %>'),
        }
      }
    }
  }
}
