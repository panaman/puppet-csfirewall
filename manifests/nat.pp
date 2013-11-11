class csfirewall::nat(
  $enable_nat = "",
  $lan        = $csfirewall::lan,
  $wan        = $csfirewall::wan,
  ) inherits csfirewall {
  if ($wan == '') {
    $ext_iface = $hostint
  } else {
    $ext_iface = $wan
  }
  $int_iface = $lan
  if ($lan == $wan) {
    notify{'LAN and WAN interfaces are the same':}
  } else {} 
  if ($enable_nat == true) {
    $ensure_nat = 'present'
    $ipforward  = '1'
  } else {
    $ensure_nat = 'absent'
    $ipforward  = '0'
  }
  augeas { 'forward_sysctl_conf':
    lens    => "sysctl.lns",
    incl    => "/etc/sysctl.conf",
    changes => "set net.ipv4.ip_forward $ipforward",
    notify  => Exec['sysctl_ip_forward'],
  } 
  exec { "sysctl_ip_forward":
    command     => "/sbin/sysctl -w net.ipv4.ip_forward=$ipforward",
    refreshonly => true,
  } ->
  file { '/etc/csf/csfpost.sh':
    ensure  => $ensure_nat,
    owner   => '0',
    group   => '0',
    mode    => '0755',
    content => template('csfirewall/csfpost.sh.erb'),
    require => Exec['install_csf'],
    notify  => Service['csf'],
  }
}
