hello world git from johnsnoww!


vagrant@localhost:/etc/puppetlabs/code/environments/production$ pwd
/etc/puppetlabs/code/environments/production
vagrant@localhost:/etc/puppetlabs/code/environments/production$ ll
total 32
drwxr-xr-x 6 root root 4096 Mar 22 13:57 ./
drwxr-xr-x 5 root root 4096 Mar 16 09:59 ../
drwxr-xr-x 8 root root 4096 Mar 22 15:00 .git/
-rw-r--r-- 1 root root   33 Mar 16 10:01 README.md
drwxr-xr-x 2 root root 4096 Mar 22 14:05 data/
drwxr-xr-x 2 root root 4096 Mar 16 10:01 files/
-rw-r--r-- 1 root root  129 Mar 22 13:56 hiera.yaml
drwxr-xr-x 2 root root 4096 Mar 16 10:15 manifests/
vagrant@localhost:/etc/puppetlabs/code/environments/production$ 

vagrant@localhost:/etc/puppetlabs/code/environments/production$ ll data/
total 12
drwxr-xr-x 2 root root 4096 Mar 22 14:05 ./
drwxr-xr-x 6 root root 4096 Mar 22 13:57 ../
-rw-r--r-- 1 root root  759 Mar 22 14:05 common.yaml
vagrant@localhost:/etc/puppetlabs/code/environments/production$ cat data/common.yaml 
---
  test: 'This is a test john'
  consul_node: true
  apache_pkg: 'apache2'
  apache_worker_factor: 100
  apparmor_enabled: true
  syslog_server: '10.170.81.32'
  monitor_ips:
    - '10.179.203.46'
    - '212.100.235.160'
    - '10.181.120.77'
    - '94.236.56.148'
  cobbler_config:
    manage_dhcp: 1
    pxe_just_once: 1
  domain: 'bitfieldconsulting.com'
  servername: 'www.bitfieldconsulting.com'
  port: 80
  docroot: '/var/www/bitfieldconsulting.com'
  dns_allow_query: true
  backup_retention_days: 10
  backup_path: "/backup/%{facts.hostname}"
  ips:
    home: '130.190.0.1'
    office1: '74.12.203.14'
    office2: '95.170.0.75'
  firewall_allow_list:
    - "%{lookup('ips.home')}"
    - "%{lookup('ips.office1')}"
    - "%{lookup('ips.office2')}"
vagrant@localhost:/etc/puppetlabs/code/environments/production$ cat hiera.yaml 
---
version: 5

defaults:
  datadir: data
  data_hash: yaml_data

hierarchy:
  - name: "Common defaults"
    path: "common.yaml"
vagrant@localhost:/etc/puppetlabs/code/environments/production$ 



s109 & 149
