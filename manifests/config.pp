# metricbeat::config
# @api private
#
# Manages the state and contests of Metricbeat's configuration file
#
# @summary Manages Metricbeat's configuration file
class metricbeat::config {
  # # Use lookup to merge metricbeat::modules config from different levels of hiera
  # $modules_lookup = lookup('metricbeat::modules', undef, 'unique', undef)
  # # Check to see if anything has been confiugred in hiera
  # if $modules_lookup {
  #   $modules_arr = $modules_lookup
  # # check if array is empty, no need to create a config entry then
  # } elsif $metricbeat::modules[0].length() > 0 {
  #   $modules_arr = $metricbeat::modules
  # } else {
  #   $modules_arr = undef
  # }

  # if fields are "under root", then remove prefix
  if $metricbeat::fields_under_root == true {
    $fields_tmp = $metricbeat::fields.each | $key, $value | { { $key => $value } }
  } else {
    $fields_tmp = $metricbeat::fields
  }

  $metricbeat_config_base = delete_undef_values( {
      'cloud.id'                                 => $metricbeat::cloud_id,
      'cloud.auth'                               => $metricbeat::cloud_auth,
      'name'                                     => $metricbeat::beat_name,
      'tags'                                     => $metricbeat::tags,
      'logging'                                  => $metricbeat::logging,
      'processors'                               => $metricbeat::processors,
      'queue'                                    => $metricbeat::queue,
      'setup'                                    => $metricbeat::setup,
      'fields_under_root'                        => $metricbeat::fields_under_root,
      'output'                                   => $metricbeat::outputs,
      'metricbeat.autodiscover.providers'        => $metricbeat::autodiscover,
      'metricbeat.config.modules.reload.enabled' => $metricbeat::reload,
      'metricbeat.config.modules.path'           => "${metricbeat::config_dir}/modules.d/*.yml",
      'monitoring'                               => $metricbeat::monitoring,
  })

  if $fields_tmp {
    $fields_tmp2 = { 'fields' => $fields_tmp, }
    $metricbeat_config_temp = deep_merge( $metricbeat_config_base, $fields_tmp2 )
  } else {
    $metricbeat_config_temp = $metricbeat_config_base
  }

  # Add the 'xpack' section if supported (version >= 6.2.0)
  if versioncmp($metricbeat::package_ensure, '6.2.0') >= 0 {
    $metricbeat_config = deep_merge($metricbeat_config_temp, { 'xpack' => $metricbeat::xpack })
  }
  else {
    $metricbeat_config = $metricbeat_config_temp
  }

  case $facts['kernel'] {
    'Linux': {
      $q = undef
      $slash = '/'
    }
    'Windows': {
      $cmd_install_dir = regsubst($metricbeat::install_dir, '/', '\\', 'G')
      $metricbeat_path = join([$cmd_install_dir, 'Metricbeat', 'metricbeat.exe'], '\\')
      $q = '"'
      $slash = "\\"
    }
    default: {
      fail("${facts['kernel']} is not supported by metricbeat.")
    }
  }

  $validate_cmd    = $metricbeat::disable_configtest ? {
    true    => undef,
    default => "${q}${metricbeat::metricbeat_path}${q} -c ${q}${metricbeat::config_dir}${slash}metricbeat.yml${q} test config",
  }

  file { 'metricbeat.yml':
    ensure       => $metricbeat::ensure,
    path         => "${metricbeat::config_dir}/metricbeat.yml",
    owner        => $metricbeat::owner,
    group        => $metricbeat::group,
    mode         => $metricbeat::config_mode,
    content      => inline_template('<%= @metricbeat_config.to_yaml() %>'),
    validate_cmd => $validate_cmd,
  }
}
