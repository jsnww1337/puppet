class profile::dnsbind::server {

include 'bind'

bind::zone {'example.com':
  ensure       => 'present',
  zone_contact => 'contact.example.com',
  zone_ns      => ['ns0.example.com'],
  zone_serial  => '2012120201',
  zone_ttl     => '7200',
  zone_origin  => 'example.com',
  zone_type    => 'master',
}

bind::a {'example.com':
  ensure    => 'present',
  zone      => 'example.com',
  ptr       => false,
  hash_data => {
    'host1' => { owner => '10.20.30.40', },
    'host2' => { owner => '11.22.33.44', },
  },
}
}
