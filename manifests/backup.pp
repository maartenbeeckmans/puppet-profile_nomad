#
#
#
class profile_nomad::backup (
  String $data_dir = $::profile_nomad::data_dir,
) {
  include profile_rsnapshot::user

  @@rsnapshot::backup{ "backup ${facts['networking']['fqdn']} nomad-data":
    source     => "rsnapshot@${facts['networking']['fqdn']}:${data_dir}",
    target_dir => "${facts['networking']['fqdn']}/nomad_data",
    tag        => lookup('rsnapshot_tag', String, undef, 'rsnapshot'),
  }
}
