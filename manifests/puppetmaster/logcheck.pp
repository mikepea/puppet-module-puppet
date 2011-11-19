
class puppet::puppetmaster::logcheck {
    file { "/etc/logcheck/ignore.d.server/local-puppetmasterd":
         mode => 444,
         content => template("puppet/puppetmasterd.logcheck_ignore"),
    }
}
