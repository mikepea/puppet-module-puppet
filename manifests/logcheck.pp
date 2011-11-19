
class puppet::logcheck {
    file { "puppetd_logcheck":
        path => "/etc/logcheck/ignore.d.server/local-puppetd",
        mode => 444,
        content => template("puppet/puppetd.logcheck_ignore"),
    }
}

