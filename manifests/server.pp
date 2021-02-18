#
#
#
class profile_nomad::server (
  String               $advertise_address          = $::profile_nomad::advertise_address,
  String               $alloc_dir                  = $::profile_nomad::alloc_dir,
  Boolean              $auto_advertise             = $::profile_nomad::auto_advertise,
  String               $bind_address               = $::profile_nomad::bind_address,
  String               $root_ca_file               = $::profile_nomad::root_ca_file,
  String               $cert_file                  = $::profile_nomad::cert_file,
  Boolean              $client                     = $::profile_nomad::client,
  Boolean              $client_auto_join           = $::profile_nomad::client_auto_join,
  String               $client_service_name        = $::profile_nomad::client_service_name,
  String               $collection_interval        = $::profile_nomad::collection_interval,
  String               $consul_address             = $::profile_nomad::consul_address,
  String               $consul_root_ca_file        = $::profile_consul::root_ca_file,
  String               $consul_cert_file           = $::profile_consul::cert_file,
  String               $consul_key_file            = $::profile_consul::key_file,
  Boolean              $consul_ssl                 = $::profile_nomad::consul_ssl,
  Boolean              $consul_verify_ssl          = $::profile_nomad::consul_verify_ssl,
  String               $datacenter                 = $::profile_nomad::datacenter,
  String               $region                     = $::profile_nomad::region,
  String               $data_dir                   = $::profile_nomad::data_dir,
  String               $key_file                   = $::profile_nomad::key_file,
  String               $log_level                  = $::profile_nomad::log_level,
  Hash                 $meta                       = $::profile_nomad::meta,
  String               $network_iface              = $::profile_nomad::network_iface,
  String               $node_name                  = $::profile_nomad::node_name,
  Hash                 $plugin_config              = $::profile_nomad::plugin_config,
  Boolean              $prometheus_metrics         = $::profile_nomad::prometheus_metrics,
  Boolean              $publish_allocation_metrics = $::profile_nomad::publish_allocation_metrics,
  Boolean              $publish_node_metrics       = $::profile_nomad::publish_node_metrics,
  Boolean              $rejoin_after_leave         = $::profile_nomad::rejoin_after_leave,
  String               $encrypt_key                = $::profile_nomad::encrypt_key,
  Boolean              $server_auto_join           = $::profile_nomad::server_auto_join,
  String               $server_service_name        = $::profile_nomad::server_service_name,
  Boolean              $telemetry_disable_hostname = $::profile_nomad::telemetry_disable_hostname,
  Boolean              $tls_http                   = $::profile_nomad::tls_http,
  Boolean              $tls_rpc                    = $::profile_nomad::tls_rpc,
  Hash                 $vault_config               = $::profile_nomad::vault_config,
  String               $vault_role                 = $::profile_nomad::vault_role,
  String               $vault_token                = $::profile_nomad::vault_token,
  Boolean              $verify_https_client        = $::profile_nomad::verify_https_client,
  Boolean              $verify_server_hostname     = $::profile_nomad::verify_server_hostname,
  Boolean              $verify_ssl                 = $::profile_nomad::verify_ssl,
  Stdlib::Absolutepath $config_dir                 = $::profile_nomad::config_dir,
  Boolean              $manage_repo                = $::profile_nomad::manage_repo,
  String               $version                    = $::profile_nomad::version,
  Boolean              $manage_sd_service          = $::profile_nomad::manage_sd_service,
  String               $sd_service_name            = $::profile_nomad::sd_service_name,
  Array                $sd_service_tags            = $::profile_nomad::sd_service_tags,
) {
  $_server_results = puppetdb_query("resources[certname] { type=\"Class\" and title = \"Profile_nomad::Server\" }")
  $_server_nodes = sort($_server_results.map | $result | { "${result['certname']}:4647" })
  $_agent_results = puppetdb_query("resources[certname] { type=\"Class\" and title = \"Profile_nomad::Agent\" }")
  $_agent_nodes = sort($_agent_results.map | $result | { "${result['certname']}:4647" })


  $_extra_vault_config = {
    token            => $vault_token,
    create_from_role => $vault_role,
  }

  $_vault_config = deep_merge($vault_config, $_extra_vault_config)
  $_config_hash = {
    advertise   => {
      http => $advertise_address,
      rpc  => $advertise_address,
      serf => $advertise_address,
    },
    bind_addr   => $bind_address,
    client      => {
      alloc_dir         => $alloc_dir,
      enabled           => $client,
      meta              => $meta,
      network_interface => $network_iface,
      servers           => $_server_nodes,
    },
    consul      => {
      address             => $consul_address,
      auto_advertise      => $auto_advertise,
      ca_file             => $consul_root_ca_file,
      cert_file           => $consul_cert_file,
      client_auto_join    => $client_auto_join,
      client_service_name => $client_service_name,
      key_file            => $consul_key_file,
      server_auto_join    => $server_auto_join,
      server_service_name => $server_service_name,
      ssl                 => $consul_ssl,
      verify_ssl          => $verify_ssl,
    },
    datacenter  => $datacenter,
    region      => $region,
    data_dir    => $data_dir,
    log_level   => $log_level,
    name        => $node_name,
    plugin      => $plugin_config,
    server      => {
      bootstrap_expect   => size($_server_nodes),
      data_dir           => $data_dir,
      enabled            => true,
      rejoin_after_leave => $rejoin_after_leave,
      encrypt            => $encrypt_key,
    },
    server_join => {
      retry_join => concat($_server_nodes, $_agent_nodes),
    },
    telemetry   => {
      collection_interval        => $collection_interval,
      disable_hostname           => $telemetry_disable_hostname,
      prometheus_metrics         => $prometheus_metrics,
      publish_allocation_metrics => $publish_allocation_metrics,
      publish_node_metrics       => $publish_node_metrics,
    },
    tls         => {
      ca_file                => $root_ca_file,
      cert_file              => $cert_file,
      http                   => $tls_http,
      key_file               => $key_file,
      rpc                    => $tls_rpc,
      verify_https_client    => $verify_https_client,
      verify_server_hostname => $verify_server_hostname,
    },
    vault       => $_vault_config,
  }

  class { 'nomad':
    config_dir     => $config_dir,
    config_hash    => $_config_hash,
    version        => $version,
    install_method => 'package',
    bin_dir        => '/usr/bin',
    manage_repo    => $manage_repo,
  }

  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http            => "https://${advertise_address}:4646",
          interval        => '10s',
          tls_skip_verify => true,
        }
      ],
      port   => 4646,
      tags   => $sd_service_tags,
    }
  }
}
