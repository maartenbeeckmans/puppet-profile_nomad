#
class profile_nomad (
  Hash $config                                = {},
  Hash $config_defaults                       = {
    'consul' => {
      'address' => '127.0.0.1:8500',
    },
    'data_dir'   => '/var/lib/nomad',
    'datacenter' => 'beeckmans.io',
  },
  Stdlib::Absolutepath $config_dir            = '/etc/nomad.d',
  Boolean              $consul_connect        = false,
  String               $job_port_range        = '20000-32000',
  Boolean              $manage_firewall_entry = true,
  Boolean              $manage_sd_service     = true,
  Boolean              $manage_sysctl         = true,
  String               $sd_service_name       = 'nomad-ui',
  Array                $sd_service_tags       = [],
  String               $version               = '0.12.7',
  Boolean              $manage_repo           = true,
  String               $repo_gpg_key          = 'E8A032E094D8EB4EA189D270DA418C88A3219F7B',
  Stdlib::HTTPUrl      $repo_gpg_url          = 'https://apt.releases.hashicorp.com/gpg',
  Stdlib::HTTPUrl      $repo_url              = 'https://apt.releases.hashicorp.com',
) {
  if $consul_connect {
    include profile_nomad::cni_plugins

    if $manage_sysctl {
      sysctl { 'net.bridge.bridge-nf-call-arptables':
        ensure => present,
        value  => '1',
      }
      sysctl { 'net.bridge.bridge-nf-call-iptables':
        ensure => present,
        value  => '1',
      }
    }
  }
  if $manage_repo {
    if ! defined(Apt::Source['Hashicorp']) {
      apt::source { 'Hashicorp':
        location => $repo_url,
        repos    => 'main',
        key      => {
          id     => $repo_gpg_key,
          server => $repo_gpg_url,
        }
      }
    }
  }
  class { 'nomad':
    config_defaults => $config_defaults,
    config_dir      => $config_dir,
    config_hash     => $config,
    version         => $version,
    install_method  => 'package',
    bin_dir         => '/usr/bin',
  }
  if $manage_firewall_entry {
    firewall { '20000 allow Nomad services':
      dport  => [$job_port_range],
      action => 'accept',
    }
    firewall { '04646 allow Nomad http':
      dport  => 4646,
      action => 'accept',
    }
    firewall { '04647 allow Nomad rpc':
      dport  => 4647,
      action => 'accept',
    }
    firewall { '04648 allow Nomad serf':
      dport  => 4648,
      action => 'accept',
    }
  }
  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http     => "http://${facts['networking']['ip']}:4646",
          interval => '10s'
        }
      ],
      port   => 4646,
      tags   => $sd_service_tags,
    }
  }
}
