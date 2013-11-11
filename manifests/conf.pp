class csfirewall::conf(
  $testing          = '1',
  $testing_interval = '9',
  $poop = '3',
  ) {
  augeas { 'csf_conf':
    context => "/files/etc/csf/csf.conf",
    changes => [
      "set TESTING $testing",
      "set TESTING_INTERVAL $testing_interval",
      "set POOP $poop",
    ],
  }
  augeas { 'geo':
    context => "/files/etc/GeoIP.conf",
    changes => [
      "set UserId poop",
    ],
  }
  file { "/tmp/$poop.txt":
    ensure => present,
  }
}

