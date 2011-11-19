
Puppetmaster Bootstrap files
----------------------------

These files are designed to be run using the direct 'puppet' client 
mode (rather than puppetd), with the express purpose of creating a 
passenger based puppetmaster on the node than can then serve itself 
(and others) with puppetd.


First Stage - get modules from SVN
----------------------------------

Run the very simple:

puppet ./bootstrap_pm_stage_1.pp

This will create a bunch of directories, and most importantly adds 
the puppvcs user and checks out all the puppet modules from SVN.


Second Stage - set up a puppetmaster
------------------------------------

puppet   --modulepath=/var/lib/puppet/modules --manifestdir="/etc/puppet/manifests" --pluginsync --factpath=/var/lib/puppet/lib/facter:/var/lib/puppet/facts:/var/lib/puppet/fileserver/facts/ ./bootstrap_pm_stage_2.pp


