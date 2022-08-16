# @summary Install, configures and manages Metricbeat on the target node.
#
# A description of what this class does
#
# @example
#  class{'metricbeat':
#    modules => [
#      {
#        'module'     => 'apache',
#        'metricsets' => ['status'],
#        'hosts'      => ['http://localhost'],
#      },
#    ],
#    outputs => {
#      'elasticsearch' => {
#        'hosts' => ['http://localhost:9200'],
#      },
#    },
#  }
#
# Parameters
# ----------
#
# * `apt_repo_url`
# [String] The URL of the APT repository to install Metricbeat from. Only
# applicable on Debian systems. Default: https://artifacts.elastic.co/packages/${metricbeat::major_version}.x/apt
#
# * `cloud_id`
# [String] The cloud.id setting overwrites the `output.elasticsearch.hosts` and
# `setup.kibana.host` options. You can find the `cloud.id` in the Elastic Cloud
# web UI. Default: undef
#
# * `cloud_auth`
# [String] The cloud.auth setting overwrites the `output.elasticsearch.username`
# and `output.elasticsearch.password` settings. The format is `<user>:<pass>`.
# Default: undef
#
# * `modules`
# Array[Hash] The array of modules this instance of metricbeat will
# enable/configure. (default: [{}])
#
# * `outputs`
# [Hash] Configures the output(s) this Metricbeat instance should send
# to. (default: {})
#
# * `beat_name`
# [String] The name of the beat which is published as the `beat.name`
# field of each transaction. (default: $facts['hostname'])
#
# * `config_dir`
# [String] The absolute path to the configuration folder location. (default:
# /etc/metricbeat on Linux, C:/Program Files/Metricbeat on Windows)
#
# * `config_mode`
# [String] The file permission mode of the config file. Must be in Linux
# octal format. Default: '0600'
#
# * `disable_configtest`
# [Boolean] If true disable configuration file testing. It is generally
# recommended to leave this parameter at its default value. (default: false)
#
# * `download_url`
# Optional[Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]] The URL of the ZIP
# file to download. Only valid on Windows nodes. (default: undef)
#
# * `ensure`
# [String] Ensures that all required resources are managed or removed
# from the target node. This is good for bulk uninstallation across a
# network. Valid values are 'present' or 'absent'. (default: 'present')
#
# * `fields`
# Optional[Hash] Optional fields to add to each transaction to provide
# additonal information. (default: undef)
#
# * `fields_under_root`
# [Boolean] Custom fields are added to each transaction under the `fields`
# sub-dictionary. When this is true custom fields are added to the top
# level dictionary of each transaction. (default: false)
#
# * `install_dir`
# Optional[String] The absolute path to the location where metricbeat will
# be installed. Only applicable on Windows. (default: C:/Program Files)
#
# * `logging`
# [Hash] The configuration section of File['metricbeat.yml'] for the
# logging output.
#
# * `major_version`
# [Enum] The major version of Metricbeat to install from vendor repositories.
# Valid values are '5', '6' and '7'. (default: '5')
#
# * `manage_repo`
# [Boolean] Weather the upstream (elastic) repository should be
# configured. (default: true)
#
# * 'modules'
# [Hash] Array of modules and whether or not they should be enabled or disabled.
# (default: undef)
#
# * `package_ensure`
# [String] The desired state of Package['metricbeat']. Only valid when
# $ensure is present. On Windows this is the version number of the package.
# (default: 'present')
#
# * `processors`
# Optional[Array[Hash]] An optional list of dictionaries to configure
# processors, provided by libbeat, to process events before they are
# sent to the output. (default: undef)
#
# * `proxy_address*
# Optional[Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]] The Proxy server used
# for downloading files. (default: undef)
#
# * `queue`
# [Hash] Configure the internal queue before being consumed by the output(s)
# in bulk transactions. As of 6.0 only a memory queue is available, all
# settings must be configured by example: { 'mem' => {...}}.
#
# * `queue_size`
# [Integer] The size of the internal queue for single events in the
# processing pipeline. This is only applicable if $major_version is '5'.
# (default: 1000)
#
# * `service_ensure`
# [String] The desirec state of Service['metricbeat']. Only valid when
# $ensure is present. Valid values are 'enabled', 'disabled', 'running'
# or 'unmanaged'. (default: 'enabled')
#
# * `tags`
# Optional[Array[String]] An optional list of values to include in the
# `tag` field of each published transaction. This is useful for
# identifying groups of servers by logical property. (default: undef)
#
# * `tmp_dir`
# [String] The absolute path to the temporary directory. On Windows, this
# is the target directory for the ZIP file download. (default: /tmp on
# Linux, C:\Windows\Temp on Windows)
#
# * `url_arch
# Optional[String] An optional string describing the architecture of
# the target node. Only applicable on Windows nodes. (default: x86 or x64)
#
# * `xpack`
# Optional[Hash] Configuration items to export internal stats to a
# monitoring Elasticsearch cluster
#
# * `yum_repo_url`
# [String] The URL of the YUM repo to install Metricbeat from. Only
# applicable on RedHat or Suse based systems.
# Default: https://artifacts.elastic.co/packages/${metricbeat::major_version}.x/yum
class metricbeat (
  String $config_dir,
  Hash $logging,
  String $metricbeat_path,
  Hash $queue,
  String $tmp_dir,
  Hash $outputs                                                       = { 'elasticsearch' => { 'hosts' => ['http://localhost:9200'] } },
  String $beat_name                                                   = $facts['networking']['hostname'],
  Boolean $disable_configtest                                         = false,
  Enum['present', 'absent'] $ensure                                   = 'present',
  Enum['6', '7'] $major_version                                       = '7',
  Boolean $manage_repo                                                = true,
  String $package_ensure                                              = 'present',
  Integer $queue_size                                                 = 1000,
  Enum['enabled', 'disabled', 'running', 'unmanaged'] $service_ensure = 'enabled',
  String $config_mode                                                 = '0644',
  Optional[Hash] $modules                                             = undef,
  Optional[Hash] $custom_modules                                      = undef,
  Optional[Boolean] $reload                                           = undef,
  Optional[Array[Hash]] $autodiscover                                 = undef,
  Optional[Array[Hash]] $setup                                        = undef,
  Optional[Array[Hash]] $monitoring                                   = undef,
  Optional[Array[String]] $tags                                       = undef,
  Optional[Array[Hash]] $processors                                   = undef,
  Optional[Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]] $proxy_address = undef,
  Optional[String] $install_dir                                       = undef,
  Optional[Hash] $fields                                              = undef,
  Optional[Boolean] $fields_under_root                                = undef,
  Optional[String] $owner                                             = undef,
  Optional[String] $group                                             = undef,
  Optional[Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]] $download_url  = undef,
  Optional[Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]] $apt_repo_url  = undef,
  Optional[String] $cloud_id                                          = undef,
  Optional[String] $cloud_auth                                        = undef,
  Optional[String] $url_arch                                          = undef,
  Optional[Hash] $xpack                                               = undef,
  Optional[Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]] $yum_repo_url  = undef,
) {
  if $manage_repo {
    class { 'metricbeat::repo': }

    Class['metricbeat::repo']
    -> Class['metricbeat::install']
  }

  if $ensure == 'present' {
    Anchor['metricbeat::begin']
    -> Class['metricbeat::install']
    -> Class['metricbeat::config']
    # -> Class['metricbeat::modules']
    ~> Class['metricbeat::service']

    Class['metricbeat::install']
    ~> Class['metricbeat::service']
  }
  else {
    Anchor['metricbeat::begin']
    -> Class['metricbeat::service']
    -> Class['metricbeat::install']
  }

  anchor { 'metricbeat::begin': }
  class { 'metricbeat::config': }
  # class{'metricbeat::modules':}
  class { 'metricbeat::install': }
  class { 'metricbeat::service': }
}
