
class puppet::vcsuser {
    # User for managing getting manifests et al from VCS (svn, git...)
    realize Group['puppvcs']
    realize User['puppvcs']
}

