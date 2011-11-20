
File { owner => root, group => root }

define git_clone (
            $module_name,
            $repo,
            $cwd = "/var/lib/puppet/modules",
            $path = "/bin:/usr/bin"
	) {
    exec { "git_clone_${module_name}":
        path => $path,
        require => Package['git-core'],
        cwd => $cwd,
        command => "git clone ${repo} ${module_name}",
        unless => "test -d ${cwd}/${module_name}",
        user => 'puppvcs',
        group => 'puppvcs',
    }
}

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

git_clone { "puppetlabs-vcsrepo":
    module_name => "vcsrepo",
    repo => 'git://github.com/puppetlabs/puppet-vcsrepo.git',
}

git_clone { "mikepea-puppet":
    module_name => "puppet",
    repo => 'git://github.com/mikepea/puppet-module-puppet.git',
}

file { "/var/lib/puppet/fileserver":
	ensure => directory,
	mode => 2750,
	owner => puppvcs,
	group => puppet,
	#before => Exec["checkout_puppet_modules"],
}

file { "/var/lib/puppet/modules":
	ensure => directory,
	mode => 2750,
	owner => puppvcs,
	group => puppet,
	#before => Exec["checkout_puppet_modules"],
}

file { "/etc/puppet/manifests":
	ensure => directory,
	mode => 2750,
	owner => puppvcs,
	group => puppet,
	#before => Exec["checkout_puppet_modules"],
}

file { "/etc/puppet/manifests/nodes":
	ensure => directory,
	mode => 2750,
	owner => puppvcs,
	group => puppet,
}

