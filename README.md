Hello world git from johnsnoww!
=================================================================================
**Hiera**
> hiera.yaml - config file

    ---
    version: 5

    defaults:
      datadir: data
      data_hash: yaml_data

    hierarchy:
      - name: "Common defaults"
        path: "common.yaml"
  
> lookup2.pp - manifest with lookup

    $apache_pkg = lookup('apache_pkg')

    unless lookup('apparmor_enabled') {
      exec { 'apt-get -y remove apparmor': }
    }

    notice('dns_allow_query enabled: ', lookup('dns_allow_query'))


> data/common.yaml - hiera data, bunch of values

    ---
      test: 'This is a test'
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

=================================================================================
https://stackoverflow.com/questions/49694314/how-to-install-apache-in-puppet-with-node-roles-profiles
How to install apache in puppet with node roles profiles

Scenario: install apache with node, roles, profiles approach. The `puppet agent -t` run went fine. <br> File resource created: `/tmp/example-ip` In web browser go to: `localhost:80` Search for any folder with name apache `find / -type d -name *apache*` see if anything appears. Verify installation by going to: localhost:80
======= CODE =======
**Code:**

> node_modules.pp

    # controls nodes with node -> role -> profile approach
    node 'puppetagent-01-dev.dev' {
      include role::app_server
    }
    
    node 'puppetagent-01-test.dev' {
      include role::db_server
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
How to install puppet step-by-step scenario:

Resources:
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
3.  Optional - set repo to access puppet:
    vim /etc/yum.repos.d/puppetlabs-pc1.repo
    content: 
    ...
    [puppetlabs-pc1]
    gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs-PC1
          file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-PC1
    ...
    [puppetlabs-pc1-source]
    gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs-PC1
          file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-PC1
    ...
4.  Optional - set RPM GPG KEY puppet manual edit or scp from master: 
    vim /etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-PC1 
    and 
    RPM-GPG-KEY-puppetlabs-PC1
    
    terminal where 192.168.253.6 and 192.168.253.5 are agent 1 and agent 2 ip's and /tmp is in which folder file placed target machine: 
    scp /etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-PC1 username@192.168.253.6:/tmp
    scp /etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs-PC1 username@192.168.253.6:/tmp
    scp /etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-PC1 username@192.168.253.5:/tmp
    scp /etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs-PC1 username@192.168.253.5:/tmp
    
6.  Move keys in host vms terminals: 
    mv /tmp/RPM-GPG-KEY-puppet-PC1 /etc/pki/rpm-gpg/
    mv /tmp/RPM-GPG-KEY-puppetlabs-PC1 /etc/pki/rpm-gpg/
    
7.  clean yum cache: 
    yum clean all
8.  yum make cache:
    yum makecache fast
    
9.  Install puppet master and puppet agent, as listed in yum install -auto complete- or yum search for puppet:
    Master vm command: yum install puppetserver.noarch
    Agent vm: yum install puppet-agent.x86_64

10.  Check VMS IP inetaddr on both master and agent: ifconfig
11.  set hostname on both master and the two agents:
    Master: vim /etc/hostname
    Content:
            puppetmaster-01-dev.dev
    Agent: vim /etc/hostname
    Content: 
            puppetagent-01-dev.dev
12.  edit /etc/hosts
    Master: vim /etc/hosts
    Content add a new last row: 
            192.168.253.4 puppetmaster-01-dev.dev
    Agent: vim /etc/hosts
    Content add two new last rows: 
            192.168.253.5 puppetagent-01-dev.dev
            192.168.253.4 puppetmaster-01-dev.dev
13.  edit /etc/puppetlabs/puppet/puppet.conf files in master:
    Master: vim /etc/puppetlabs/puppet/puppet.conf
    Content: 
            [main]
            server = puppetmaster-01.dev.dev
            certname = puppetmaster-01.dev.dev
__SKIP ME___            
            [master]
            .... add to buttom of all rows ....
            dns_alt_name = puppetmaster-01.dev.dev
14.   start puppet master: systemctl start puppetserver.service
15.   enable puppetmaster on master server boot: systemctl enable puppetserver
16.   check if puppetmaster is started: systemctl is-active puppetserver.service
17.   check if puppetmaster is enabled: systemctl is-enabled puppetserver.service
18.   edit /etc/hosts/puppetlabs/puppet/puppet.conf files the two agents: 
  Agent1: vim /etc/puppetlabs/puppet/puppet.conf
  Content: 
            .... add to buttom of all rows ....
            [main]
            certname = puppetagent-01-dev.dev
            server = puppetmaster-01-dev.dev

  Agent2: vim /etc/puppetlabs/puppet/puppet.conf
  Content: 
            .... add to buttom of all rows ....
            [main]
            certname = puppetagent-01-test.dev
            server = puppetmaster-01-dev.dev

19. puppetmaster list all pending certificates: puppet cert list
20. puppetmaster list all pending and signed certs: puppet cert list --all
21. master and agent print current cert name: puppet config print certname
22. sign a cert where puppetagent-01-dev.dev is the agent cert: puppet cert sign puppetagent-01-dev.dev
23. optionally sign all certs: puppet cert sign --all
24. optionally view all signed requests where "+" is signed and without are not signed certs: puppet cert list --all
25. see puppet agent cert fingerprint to match with signed on servewr: puppet agent --fingerprint
26. Agent run puppet: puppet agent -t
27. optionally enable firewall and open port 8174: iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8140 -j ACCEPT

<br>
http://garylarizza.com/blog/2014/02/17/puppet-workflow-part-2/
<br>
============= DONE =================
            
    

