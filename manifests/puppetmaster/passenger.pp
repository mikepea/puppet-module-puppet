
class puppet::puppetmaster::passenger {

    $puppetmaster_servertype = 'passenger'

    include puppet::puppetmaster

    apache::vhost { "puppetmasterd":
        template_name => "puppet/passenger-apache2.conf",
    }

    Dir { owner => root, group => puppet, mode  => 2750, } 
    File { owner => puppet, group => puppet, mode  => 0640, } 

    package { "libapache2-mod-passenger": } 
    package { "rails": }
    package { "librack-ruby": }

    dir { "/etc/puppet/rack": }
    dir { "/etc/puppet/rack/public": }

    file { "/etc/puppet/rack/config.ru": 
        source => "/usr/share/puppet/rack/puppetmasterd/config.ru"
    }

    file { "/etc/apache2/conf.d/puppetmaster": 
        content => "User puppet\nGroup puppet\n",
        owner => root,
        group => root,
        mode => 0444,
    }

    file { "/etc/default/puppetmaster":
        content => template("puppet/puppetmaster.default"),
        require => Class["puppet::puppetmaster"],
    }

}
