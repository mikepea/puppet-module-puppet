
class puppet {

    case $run_puppet_from_cron {
        "": { $run_puppet_from_cron = true }
        default: { }
    }

    $f_dir = "/var/lib/puppet/modules/puppet/files"

    package { puppet: ensure => present }
    package { facter: ensure => present } 

    File {
        owner => "root",
        group => "puppet",
        mode  => 0440,
    }

    service { puppet:
        ensure => stopped,
        pattern => "ruby /usr/sbin/puppetd -w 0"
    }

    case $operatingsystem {
        RedHat,CentOS: {
                case $lsbmajdistrelease {
                    4: {
                        package { "ruby-shadow-pbx": }
                    }
                    default: {
                        package { "ruby-shadow": }
                    }
                }
        }
        Debian,Ubuntu: {
            file { "/etc/default/puppet":
                content => template("puppet/puppet.default"),
                require => Package['puppet'],
            }
        }
    }

    file { "puppet.conf":
        path   => "/etc/puppet/puppet.conf",
        content => template("puppet/puppet.conf"),
        mode   => 0640,
    }

    file { "puppetrun":
        path   => "/usr/local/bin/puppetrun",
        content => template("puppet/puppetrun"),
        mode   => 0555,
    }

    file { "kill_puppet":
        path   => "/usr/local/bin/kill_puppet",
        content => template("puppet/kill_puppet"),
        mode   => 0555,
    }

    file { "/var/lib/puppet/state/modules":
        ensure => directory,
        mode => 1777,
    }

    # R.I's tool for looking at compiled local catalog
    file { "/usr/local/bin/parselocalconfig": 
        content => file("$f_dir/parselocalconfig"),
        mode => 0555,
    }

    if $run_puppet_from_cron {

        cron { puppetd-autoapply-cron:
            command => "[ ! -f /var/lib/puppet/state/NO_CRON_RUN ] && /usr/local/bin/puppetrun root 3600",
            user => root,
            hour => $environment ? {
                production  => [ 9, 12, 15, 18, 21 ],  # no changes to production outside of prio-supp
                testing     => [ 0, 6, 9, 12, 15, 18, 21 ], # regular changes to testing
                development => [ 1, 5, 9, 10, 12, 14, 16, 18, 20, 22 ], # very regular to development
                default     => [ 1, 5, 9, 10, 12, 14, 16, 18, 20, 22 ], # very regular to development
            },
            minute => 0,
            environment => "PATH=/usr/sbin:/usr/bin:/sbin:/bin",
            require => File['puppetrun'],
        }
    }
    
    cron { puppet-clientbucket-prune-cron:
        user => root,
        hour => 3,
        minute => 0,
        environment => "PATH=/usr/sbin:/usr/bin:/sbin:/bin",
        command => "find /var/lib/puppet/clientbucket/* -mtime +60 -size +100k -delete > /dev/null 2>&1",
    }

}

