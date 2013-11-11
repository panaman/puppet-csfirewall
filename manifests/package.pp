define csfirewall::package ($install_pkg, $plugin, $puppet_ip, $archive){
  Exec {
    path => [ '/usr/local/bin', '/usr/bin', '/bin', '/usr/sbin' ],
  }
  case $install_pkg {
    'true': {
      if ! defined_with_params(Package[perl], {'ensure' => 'present'}) {
        package { 'perl': ensure => present, }
      }
      archive { 'csf':
        ensure => $archive,
        url    => 'http://www.configserver.com/free/csf.tgz',
        extension => 'tgz',
        checksum => false,
        target => '/usr/local/src/tar',
      }
      exec { 'install_csf':
        command => "/usr/local/src/tar/csf/install.${plugin}.sh",
        creates => '/etc/csf/readme.txt',
        cwd     => '/usr/local/src/tar/csf',
        require => [ 
          Archive['csf'],
          Package['perl'],
        ],
      }
      service { 'csf':
        ensure => running,
        require => Exec['install_csf'],
      }
      cron { 'csf_update':
        ensure => present,
        user  => 'root',
        command => '/usr/sbin/csf --update 2>&1',
        hour => '03',
        minute => '30',
      }
      $block_ips = $block 
      $allow_ips = $allow
      if ( $puppet_ip != '' ) {
        exec { 'allow_puppet':
          command => "/usr/sbin/csf -a $puppet_ip [PuppetMaster]",
          unless => "grep $puppet_ip /etc/csf/csf.allow",
          require => Exec['install_csf'],
        }
      }
      File {
        ensure => present,
        owner  => '0',
        group  => '0',
        mode   => '0600',
        require => Exec['install_csf'],
        notify => Service['csf'],
      }
      file { '/etc/csf/csf.ignore':
        ensure  => present,
        content => template('csfirewall/csf.ignore.erb'),
      }
    }
    'false': {
      exec { 'uninstall_csf':
        command => '/etc/csf/uninstall.sh',
        onlyif => 'test -d /etc/csf',
      }
      cron { 'csf_update':
        ensure => absent,
      }
      file { '/usr/local/src/tar/csf':
        ensure => absent,
        force  => true,
      }
    }
  }
}
