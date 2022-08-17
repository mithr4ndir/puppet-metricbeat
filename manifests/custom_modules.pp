# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include metricbeat::custom_modules
#
# @param custom_modules Modules with custom configurations
define metricbeat::custom_modules (
  Hash $custom_modules = $metricbeat::custom_modules,
) {
  $custom_modules.each | $custom | {
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
