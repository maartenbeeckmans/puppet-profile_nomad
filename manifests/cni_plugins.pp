#
class profile_nomad::cni_plugins (
  Boolean            $manage_sysctl      = $::profile_nomad::manage_sysctl,
  String             $arch               = $::profile_nomad::cni_plugins_arch,
  Optional[String]   $download_url       = $::profile_nomad::cni_plugins_download_url,
  String             $download_url_base  = $::profile_nomad::cni_plugins_download_url_base,
  String             $download_extension = $::profile_nomad::cni_plugins_download_extension,
  String             $package_name       = $::profile_nomad::cni_plugins_package_name,
  Enum['none','url'] $install_method     = $::profile_nomad::cni_plugins_install_method,
  String             $version            = $::profile_nomad::cni_plugins_version,
) {
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
  case $install_method {
    'url': {
      $install_path = '/opt/cni/bin'
      $real_download_url = pick($download_url, "${download_url_base}/${version}/${package_name}-linux-${arch}-${version}.${download_extension}") # lint:ignore:140chars

      include '::archive'
      file { [
        '/opt/cni',
        '/opt/cni/bin']:
        ensure => directory,
      }
      -> archive { "${install_path}/cni_plugins.${download_extension}":
        ensure       => present,
        source       => $real_download_url,
        extract      => true,
        extract_path => $install_path,
        creates      => "${install_path}/bridge",
      }
    }
    'none': {}
    default: {
      fail("The provided install method ${install_method} is invalid")
    }
  }
}
