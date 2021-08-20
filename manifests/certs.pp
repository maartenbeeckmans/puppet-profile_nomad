#
#
#
class profile_nomad::certs (
  Boolean              $server           = $::profile_nomad::server,
  Stdlib::Absolutepath $root_ca_file     = $::profile_nomad::root_ca_file,
  Stdlib::Absolutepath $cert_file        = $::profile_nomad::cert_file,
  Stdlib::Absolutepath $key_file         = $::profile_nomad::key_file,
  Stdlib::Absolutepath $certs_dir        = $::profile_nomad::certs_dir,
  Boolean              $use_puppet_certs = $::profile_nomad::use_puppet_certs,
  Optional[String]     $root_ca_cert     = $::profile_nomad::root_ca_cert,
  Optional[String]     $nomad_cert       = $::profile_nomad::nomad_cert,
  Optional[String]     $nomad_key        = $::profile_nomad::nomad_key,
) {
  file { $certs_dir:
    ensure => directory,
  }
  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Service['nomad'],
  }

  if $use_puppet_certs {
    file { $root_ca_file:
      ensure => present,
      source => $facts['extlib__puppet_config']['main']['localcacert'],
    }
    file { $cert_file:
      ensure => present,
      source => $facts['extlib__puppet_config']['main']['hostcert'],
    }
    file { $key_file:
      ensure => present,
      source => $facts['extlib__puppet_config']['main']['hostprivkey'],
    }
  } else {
    file { $root_ca_file:
      ensure  => present,
      content => $root_ca_cert,
    }
    file { $cert_file:
      ensure  => present,
      content => $nomad_cert,
    }
    file { $key_file:
      ensure  => present,
      content => $nomad_key,
    }
  }
}
