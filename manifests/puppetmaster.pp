
class puppet::puppetmaster {

    $f_dir = "/var/lib/puppet/modules/puppet/files"

    File {
        owner => root,
        group => root,
        mode  => 0644,
    }

    case $operatingsystem {
        debian: { package { puppetmaster: ensure => present, } }
        centos: { package { puppet-server: ensure => present, } }
        redhat: { package { puppet-server: ensure => present, } }
    }

    #required for       metrics storing
    package { "rrdtool" : ensure => present}
    package { "librrd2-dev" : ensure => present}

    #might need to use patched gem files/RubyRRDtool-0.6.0.gem
    #Provide rrdtool.so bindings to the rrdtool file
    #MP# Requires RubyGems 1.4+, which ain't happening...
    #MP#package { "auxesis-RubyRRDtool":
    #MP#    provider => "gem" ,
    #MP#    ensure => present,
    #MP#}
    
    case $architecture {
        "i386": { $ruby_arch="i486-linux"}
        "amd64":{ $ruby_arch="x86_64-linux"}
    }
    
    #is this still required?
    file { "/usr/lib/ruby/1.8/${ruby_arch}/RRDtool.so":
        content => file("${f_dir}/RRDtool.so"),
    }
    
    file { "/usr/lib/ruby/1.8/${ruby_arch}/RRD.so":
        content => file("${f_dir}/RRD.so"),
    }

    # User for managing getting manifests et al from VCS (svn, git...)
    realize Group['puppvcs']
    realize User['puppvcs']

    if $puppetmaster_servertype != 'passenger' {
        #requires the puppetservice which contains the puppet.conf template
        service { puppetmaster:
            name   => $operatingsystem ? {
                default => "puppetmaster"
            },
            ensure => running,
            enable => false,
            require => Class["puppet::service"],
        }
    }

    case $environment {
        development: {    
            #list of domains that we autosign cerificates for.
            file { "/etc/puppet/autosign.conf":
                content => template("puppet/autosign.conf"),
                mode   => 0640,
                group => puppet,
            }
        }
        testing: {  #use another mechanism http://www.devco.net/archives/2010/07/14/bootstrapping_puppet_on_ec2_with_mcollective.php  
        }
        production: { #use another mechanism http://www.devco.net/archives/2010/07/14/bootstrapping_puppet_on_ec2_with_mcollective.php  
        }
    }

    file { "/etc/puppet/fileserver.conf":
        group => puppet,
        mode  => 0440,
        content => template('puppet/fileserver.conf'),
    }

    file { "/opt/semantico/bin/puppet_manifest_update":
        mode    => 0555,
        content => file("${f_dir}/puppet_manifest_update"),
    }

   # cron { "puppet_manifest_update":
   #     command => "sudo -i -u puppvcs /opt/semantico/bin/puppet_manifest_update",
   #     user => root,
   #     minute => '*/2',
   #     require => File["/opt/semantico/bin/puppet_manifest_update"],
   # }

    include puppet::puppetmaster::logcheck

    include mcollective::plugin::puppetca

    include nfs_mounts::brighton_product

}

