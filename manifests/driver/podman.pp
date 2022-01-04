#
#
#
class profile_nomad::driver::podman (
  Stdlib::Absolutepath $plugin_dir         = $::profile_nomad::plugin_dir,
  Enum['none','url']   $install_method     = $::profile_nomad::driver_podman_install_method,
  Optional[String]     $download_url       = $::profile_nomad::driver_podman_download_url,
  String               $download_url_base  = $::profile_nomad::driver_podman_download_url_base,
  String               $version            = $::profile_nomad::driver_podman_version,
  String               $package_name       = $::profile_nomad::driver_podman_package_name,
  String               $arch               = $::profile_nomad::driver_podman_arch,
  String               $download_extension = $::profile_nomad::driver_podman_download_extension,
) {
  case $install_method {
    'url': {
      $real_download_url = pick($download_url, "${download_url_base}/${version}/${package_name}_${version}_linux_${arch}.${download_extension}") # lint:ignore:140chars

      include ::archive
      archive { "${plugin_dir}/${package_name}.${download_extension}":
        ensure       => present,
        source       => $real_download_url,
        extract      => true,
        extract_path => $plugin_dir,
        creates      => "${plugin_dir}/${package_name}",
      }
    }
    'none': {}
    default: {
      fail("The provided install method ${install_method} is invalid")
    }
  }
}
