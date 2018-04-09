Hello world git from johnsnoww!


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



======================================================================================================================
https://stackoverflow.com/questions/49694314/how-to-install-apache-in-puppet-with-node-roles-profiles
how to install apache in puppet with node roles profiles

I am new to puppet and trying to install apache with node, roles, profiles approach. <br> The `puppet agent -t` run went fine. There is a file resource created: `/tmp/example-ip` but I cannot get the apache running. I used my web browser to go to: `localhost:8080` but nothing happens. searched for any folder with name apache `find / -type d -name *apache*` but nothing comes up. <br>
======= CODE =======
**Code:**

> node_modules.pp

    node 'puppet-test.dev' {
      include role::app_server
    }

> role_app_server_profiles.pp

    # Be an app server
    class role::app_server {
      include profile::apache
    }

> profile_apache.pp

    # site specific apache config for a node
    class profile::apache {
    
      ## configure apache 
      include apache
      apache::vhost { 'example.com':
        port    => '80',
        docroot => '/var/www/html',
      }
    
      ## creates a file resource
      file {'/tmp/example-ip':
        ensure  => present,
        mode    => '0644',
        content => "My ip: ${ipaddress_enp0s3}.\n",
      }
    }

======================================================================================================================
How to install puppet:

https://www.digitalocean.com/community/tutorials/how-to-install-puppet-4-in-a-master-agent-setup-on-centos-7 
https://www.youtube.com/watch?v=u9Q0Xf1G7oU&t=298s

VM: In Virtualbox preferences click: File -> Preferences -> Network -> Add a new NAT Network -> Edit NAT netwrok -> Network CIDR: 192.168.253.0/24. Network options: checked box. -> Click OK. -> On both VMS in Virtualbox click settings -> Network -> Select NAT Network -> Select created network. Do this for both VMs.

Steps to install: 
0. Configure vms and vlan (NAT Networks) in virtualbox according to "VM:" above. 
1. disable firewall on both master and agent. Commands: 
    systemctl disable firewalld
    systemctl stop firewalld
    systemctl is-enabled firewalld
    systemctl is-active firewalld
2.  enable official puppetlabs repo for, do this on both master and agent. Commands: 
    Internet goto: yum.puppetlabs.com
    Internet: copye centos version 7 .rpm link
    Internet: OS Terminal, do this for both master and agents: 
    From internet Paste: rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
3.  Install puppet master and puppet agent, as listed in yum install -auto complete- or yum search for puppet:
    Master vm command: yum install puppetserver.noarch
    Agent vm: yum install puppet
4.  Check VMS IP inetaddr on both master and agent: ifconfig
5   set hostname on both master and agent:
    Master: vim /etc/hostname
    Content:
            puppetmaster-01-dev.dev
    Agent: vim /etc/hostname
    Content: 
            puppetagent-01-dev.dev
6.  edit /etc/hosts
    Master: vim /etc/hosts
    Content add a new last row: 
            192.168.253.4 puppetmaster-01-dev.dev
    Agent: vim /etc/hosts
    Content add two new last rows: 
            192.168.253.5 puppetagent-01-dev.dev
            192.168.253.4 puppetmaster-01-dev.dev
7.  edit /etc/puppetlabs/puppet/puppet.conf files in master:
    Master: vim /etc/puppetlabs/puppet/puppet.conf
    Content: 
            [main]
            server = puppetmaster-01.dev.dev
            certname = puppetmaster-01.dev.dev
__SKIP ME___            
            [master]
            .... add to buttom of all rows ....
            dns_alt_name = puppetmaster-01.dev.dev
8.  start puppet master: systemctl start puppetserver.service
9.  enable puppetmaster on master server boot: systemctl enable puppetserver
10. check if puppetmaster is started: systemctl is-active puppetserver.service
11. check if puppetmaster is enabled: systemctl is-enabled puppetserver.service
12. edit /etc/hosts/puppetlabs/puppet/puppet.conf files in agent: 
    Agent: vim /etc/puppetlabs/puppet/puppet.conf
    Content: 
            .... add to buttom of all rows ....
            [main]
            certname = puppetagent-01-dev.dev
            server = puppetmaster-01-dev.dev
13. puppetmaster list all pending certificates: puppet cert list
14. puppetmaster list all pending and signed certs: puppet cert list --all
15. master and agent print current cert name: puppet config print certname
16. sign a cert where puppetagent-01-dev.dev is the agent cert: puppet cert sign puppetagent-01-dev.dev
17. optionally sign all certs: puppet cert sign --all
18. optionally view all signed requests where "+" is signed and without are not signed certs: puppet cert list --all
19. see puppet agent cert fingerprint to match with signed on servewr: puppet agent --fingerprint
20. Agent run puppet: puppet agent -t
21. optionally enable firewall and open port 8174: iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8140 -j ACCEPT

<br>
http://garylarizza.com/blog/2014/02/17/puppet-workflow-part-2/
<br>
============= DONE =================
            
    

