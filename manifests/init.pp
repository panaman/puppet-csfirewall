class csfirewall (
  $wan    = $csfirewall::params::wan,
  $lan    = $csfirewall::params::lan,
  $enable = $csfirewall::params::enable,
  $plugin = $csfirewall::params::plugin,
  $pm_ip  = $csfirewall::params::pm_ip,
  $nat    = $csfirewall::params::nat,
) inherits csfirewall::params {

  if ( $enable == true ) {
    $pkg = 'true'
    $archive = 'present'
  } else {
    $pkg = 'false'
    $archive = 'absent'
  }
  csfirewall::package { 'csf':
    install_pkg => $pkg,
    plugin      => $plugin,
    puppet_ip   => $pm_ip,
    archive     => $archive,
  }
  class { 'csfirewall::nat':
    enable_nat => $nat,
  }
}
