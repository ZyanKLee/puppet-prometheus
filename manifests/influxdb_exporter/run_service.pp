# == Class prometheus::influxdb_exporter::service
#
# This class is meant to be called from prometheus::influxdb_exporter
# It ensure the influxdb_exporter service is running
#
class prometheus::influxdb_exporter::run_service {

  $init_selector = $prometheus::influxdb_exporter::init_style ? {
    'launchd' => 'io.influxdb_exporter.daemon',
    default   => 'influxdb_exporter',
  }

  if $prometheus::influxdb_exporter::manage_service == true {
    service { 'influxdb_exporter':
      ensure => $prometheus::influxdb_exporter::service_ensure,
      name   => $init_selector,
      enable => $prometheus::influxdb_exporter::service_enable,
    }
  }
}
