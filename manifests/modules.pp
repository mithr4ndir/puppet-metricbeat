# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include metricbeat::modules
# @param modules Modules to enable or disable
define metricbeat::modules (
  Hash $modules = $metricbeat::modules,
) {
  if $facts['os']['family'] == 'windows' {
    $cmd = 'cmd.exe /c metricbeat.exe'
  } else {
    $cmd = $metricbeat::metricbeat_path
  }
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
