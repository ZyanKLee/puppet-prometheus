# Class prometheus::influxdb_exporter::config
# Configuration class for prometheus node exporter
class prometheus::influxdb_exporter::config(
  $purge = true,
) {

  if $prometheus::influxdb_exporter::init_style {

    case $prometheus::influxdb_exporter::init_style {
      'upstart' : {
        file { '/etc/init/influxdb_exporter.conf':
          mode    => '0444',
          owner   => 'root',
          group   => 'root',
          content => template('prometheus/influxdb_exporter.upstart.erb'),
        }
        file { '/etc/init.d/influxdb_exporter':
          ensure => link,
          target => '/lib/init/upstart-job',
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
        }
      }
      'systemd' : {
        file { '/lib/systemd/system/influxdb_exporter.service':
          mode    => '0644',
          owner   => 'root',
          group   => 'root',
          content => template('prometheus/influxdb_exporter.systemd.erb'),
        }~>
        exec { 'influxdb_exporter-systemd-reload':
          command     => 'systemctl daemon-reload',
          path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
          refreshonly => true,
        }
      }
      'sysv' : {
        file { '/etc/init.d/influxdb_exporter':
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('prometheus/influxdb_exporter.sysv.erb')
        }
      }
      'debian' : {
        file { '/etc/init.d/influxdb_exporter':
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('prometheus/influxdb_exporter.debian.erb')
        }
      }
      'sles' : {
        file { '/etc/init.d/influxdb_exporter':
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template('prometheus/influxdb_exporter.sles.erb')
        }
      }
      'launchd' : {
        file { '/Library/LaunchDaemons/io.influxdb_exporter.daemon.plist':
          mode    => '0644',
          owner   => 'root',
          group   => 'wheel',
          content => template('prometheus/influxdb_exporter.launchd.erb')
        }
      }
      default : {
        fail("I don't know how to create an init script for style ${prometheus::influxdb_exporter::init_style}")
      }
    }
  }

}
