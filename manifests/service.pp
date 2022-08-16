# metricbeat::service
# @api private
#
# Manages the state of Service['metricbeat']
#
# @summary Manages the state of Service['metricbeat']
class metricbeat::service (
  String $service_ensure         = $metricbeat::service_ensure,
) {
  # The base class must be included first because parameter defaults depend on it
  if ! defined(Class['metricbeat']) {
    fail('You must include the metricbeat class before using any metricbeat defined resources')
  }
  if $metricbeat::ensure == 'present' {
    case $service_ensure {
      'enabled': {
        $ensure = 'running'
        $enable = true
      }
      'disabled': {
        $ensure = 'stopped'
        $enable = false
      }
      'running': {
        $ensure = 'running'
        $enable = false
      }
      'unmanaged': {
        $ensure = undef
        $enable = false
      }
      default: {
        $ensure = 'running'
        $enable = true
      }
    }
  }
  else {
    $ensure = 'stopped'
    $enable = false
  }

  service { 'metricbeat':
    ensure => $ensure,
    enable => $enable,
  }
}
