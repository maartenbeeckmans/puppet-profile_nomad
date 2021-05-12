#
class profile_nomad (
  Boolean              $server,
  String               $advertise_address,
  String               $alloc_dir,
  Boolean              $auto_advertise,
  String               $bind_address,
  String               $root_ca_file,
  Boolean              $use_puppet_certs,
  Optional[String]     $root_ca_cert,
  Optional[String]     $nomad_cert,
  Optional[String]     $nomad_key,
  String               $cert_file,
  String               $certs_dir,
  Boolean              $client,
  Boolean              $client_auto_join,
  String               $client_service_name,
  String               $collection_interval,
  String               $consul_address,
  Boolean              $consul_ssl,
  Boolean              $consul_verify_ssl,
  String               $datacenter,
  String               $region,
  String               $data_dir,
  String               $key_file,
  String               $log_level,
  Hash                 $meta,
  String               $network_iface,
  String               $node_name,
  Hash                 $plugin_config,
  Boolean              $prometheus_metrics,
  Boolean              $publish_allocation_metrics,
  Boolean              $publish_node_metrics,
  Boolean              $rejoin_after_leave,
  String               $encrypt_key,
  Boolean              $server_auto_join,
  String               $server_service_name,
  Boolean              $telemetry_disable_hostname,
  Boolean              $tls_http,
  Boolean              $tls_rpc,
  Hash                 $vault_config,
  String               $vault_role,
  String               $vault_token,
  Boolean              $verify_https_client,
  Boolean              $verify_server_hostname,
  Boolean              $verify_ssl,
  Boolean              $manage_sysctl,
  String               $cni_plugins_arch,
  String               $cni_plugins_download_url_base,
  String               $cni_plugins_download_extension,
  String               $cni_plugins_package_name,
  Enum['none','url']   $cni_plugins_install_method,
  String               $cni_plugins_version,
  Stdlib::Absolutepath $config_dir,
  Boolean              $consul_connect,
  String               $job_port_range,
  Boolean              $manage_firewall_entry,
  String               $sd_service_name,
  Array                $sd_service_tags,
  String               $version,
  Boolean              $manage_repo,
  Boolean              $nomad_backup,
  Optional[String]     $cni_plugins_download_url,
  Boolean              $manage_sd_service        =lookup('manage_sd_service', Boolean, first, true),
) {
  if $server {
    include profile_nomad::server
  } else {
    include profile_nomad::agent
  }

  include profile_nomad::certs

  if $consul_connect {
    include profile_nomad::cni_plugins
  }

  if $manage_firewall_entry {
    include profile_nomad::firewall
  }
  file { '/etc/profile.d/nomad.sh':
    ensure  => file,
    mode    => '0644',
    content => "export NOMAD_ADDR=https://127.0.0.1:4646\nexport NOMAD_CACERT=${root_ca_file}\n",
  }
  if $nomad_backup {
    include profile_nomad::backup
  }
}
