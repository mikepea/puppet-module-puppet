$puppetmaster = $fqdn  # self.

define mkdir ($path = "", 
              $mode = 2755,
              $owner = "root", 
              $group = "root", 
              $ensure = "directory"
              ) {

    case $path {
        "": { $our_path = $title }
        default: { $our_path = $path }
    }
    
    case $ensure {
        "directory", "present": {
            file { "$our_path":
                ensure => directory,
                mode => $mode,
                owner => $owner,
                group => $group,
            }
        }
        "absent": {
            file { "$our_path":
                ensure => $ensure,
            }
        }
    }
}

define dir ($path = "", 
              $mode = 2755, 
              $owner = "root", 
              $group = "root", 
              $purge   = false,
              $recurse = false,
              $force   = false,
              $ensure = "directory"
              ) {

    case $path {
        "": { $our_path = $title }
        default: { $our_path = $path }
    }
    
    case $ensure {
        "directory", "present": {
            file { "$our_path":
                ensure => directory,
                mode => $mode,
                owner => $owner,
                group => $group,
                purge => $purge,
                recurse => $recurse,
                force => $force,
            }
        }
        "absent": {
            file { "$our_path":
                ensure => $ensure,
            }
        }
    }
}

define line($file, $line, $ensure = 'present') {
        case $ensure {
                default : { err ( "unknown ensure value '${ensure}'" ) }
                present: {
                        exec { "/bin/echo '${line}' >> '${file}'":
                                unless => "/bin/grep -qFx '${line}' '${file}'"
                        }
                }
                absent: {
                        exec { "/usr/bin/perl -ni -e 'print unless /^\\Q${line}\\E\$/' '${file}'":
                                onlyif => "/bin/grep -qFx '${line}' '${file}'"
                        }
                }
        }
}

$puppetmaster_servertype = 'passenger'

include puppet::puppetmaster::passenger
include puppet
