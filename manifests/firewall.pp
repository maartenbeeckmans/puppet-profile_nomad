#
#
#
class profile_nomad::firewall (
  String $job_port_range = $::profile_nomad::job_port_range,
) {
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
