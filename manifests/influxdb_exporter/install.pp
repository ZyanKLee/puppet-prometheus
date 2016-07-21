# Class prometheus::influxdb_exporter::install
# Install prometheus influxdb_exporter via different methods with parameters from init
# Currently only the install from url is implemented, when Prometheus will deliver packages for some Linux distros I will
# implement the package install method as well
# The package method needs specific yum or apt repo settings which are not made yet by the module
class prometheus::influxdb_exporter::install
{

  case $::prometheus::influxdb_exporter::install_method {
    'url': {
      include staging
      $staging_file = "influxdb_exporter-${prometheus::influxdb_exporter::version}.${prometheus::influxdb_exporter::download_extension}"
      if( versioncmp($::prometheus::influxdb_exporter::version, '0.12.0') == -1 ){
        $binary = "${::staging::path}/influxdb_exporter"
      } else {
          $binary = "${::staging::path}/influxdb_exporter-${::prometheus::influxdb_exporter::version}/influxdb_exporter"
      }
      staging::file { $staging_file:
        source => $prometheus::influxdb_exporter::real_download_url,
      } ->
      staging::extract { $staging_file:
        target  => $::staging::path,
        creates => $binary,
      } ->
      exec { 'build-influxdb_exporter-binary':
        path    => '/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin',
        command => 'go build main.go',
        cwd     => "${::staging::path}/influxdb_exporter-${::prometheus::influxdb_exporter::version}/",
        user    => 'root',
      }->
      exec { 'rename-influxdb_exporter-binary':
        path    => '/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin',
        command => 'mv main influxdb_exporter',
        cwd     => "${::staging::path}/influxdb_exporter-${::prometheus::influxdb_exporter::version}/",
        user    => 'root',
      }->
      file {
        $binary:
          owner => 'root',
          group => 0, # 0 instead of root because OS X uses "wheel".
          mode  => '0555';
        "${::prometheus::influxdb_exporter::bin_dir}/influxdb_exporter":
          ensure => link,
          notify => $::prometheus::influxdb_exporter::notify_service,
          target => $binary,
      }
    }
    'package': {
      package { $::prometheus::influxdb_exporter::package_name:
        ensure => $::prometheus::influxdb_exporter::package_ensure,
      }
      if $::prometheus::influxdb_exporter::manage_user {
        User[$::prometheus::influxdb_exporter::user] -> Package[$::prometheus::influxdb_exporter::package_name]
      }
    }
    'none': {}
    default: {
      fail("The provided install method ${::prometheus::install_method} is invalid")
    }
  }
  if $::prometheus::influxdb_exporter::manage_user {
    ensure_resource('user', [ $::prometheus::influxdb_exporter::user ], {
      ensure => 'present',
      system => true,
      groups => $::prometheus::influxdb_exporter::extra_groups,
    })

    if $::prometheus::influxdb_exporter::manage_group {
      Group[$::prometheus::influxdb_exporter::group] -> User[$::prometheus::influxdb_exporter::user]
    }
  }
  if $::prometheus::influxdb_exporter::manage_group {
    ensure_resource('group', [ $::prometheus::influxdb_exporter::group ], {
      ensure => 'present',
      system => true,
    })
  }
}
