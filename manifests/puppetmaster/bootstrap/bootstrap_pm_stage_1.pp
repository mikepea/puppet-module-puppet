
File { owner => root, group => root }

package { "pwgen": }
package { "git-core": }
package { "puppetmaster": }

group { "puppvcs": gid => 11118 }
user { "puppvcs": 
	uid => 11118,
	gid => 'puppvcs',
        comment => "Puppet Version Control System Access",
        home => "/home/puppvcs",
        shell => "/bin/bash",
}

file { "/home/puppvcs":
    ensure => directory,
    mode => 2750,
    group => puppvcs,
    owner => puppvcs,
}

exec { "vcsrepo-git":
	path => "/bin:/usr/bin",
	require => Package['git-core'],
	cwd => '/var/lib/puppet/modules',
	command => 'git clone git://github.com/puppetlabs/puppet-vcsrepo.git vcsrepo',
	unless => 'test -d /var/lib/puppet/modules/vcsrepo',
	user => 'puppvcs',
	group => 'puppvcs',
}

file { "/var/lib/puppet/fileserver":
	ensure => directory,
	mode => 2750,
	owner => puppvcs,
	group => puppet,
	before => Exec["checkout_puppet_modules"],
}

file { "/var/lib/puppet/modules":
	ensure => directory,
	mode => 2750,
	owner => puppvcs,
	group => puppet,
	before => Exec["checkout_puppet_modules"],
}

file { "/etc/puppet/manifests":
	ensure => directory,
	mode => 2750,
	owner => puppvcs,
	group => puppet,
	before => Exec["checkout_puppet_modules"],
}

file { "/etc/puppet/manifests/nodes":
	ensure => directory,
	mode => 2750,
	owner => puppvcs,
	group => puppet,
}

