# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class oracledb(
                $memory_target     = '1G',
                $manage_ntp        = true,
                $manage_tmpfs      = true,
                $ntp_servers       = undef,
                $preinstalltasks   = true,
                $createoracleusers = true,
                $griduser          = true,
                $preinstallchecks  = true,
                $add_stage         = true,
              ) inherits oracledb::params {

  if($add_stage)
  {
    stage { 'eyp-oracle-db': }

    Stage['main'] -> Stage['eyp-oracle-db']

    Class['::oracledb::users'] {
      stage => 'eyp-oracle-db',
    }
  }

  class { '::oracledb::users':
    griduser          => $griduser,
    createoracleusers => $createoracleusers,
  }

  ->

  class { 'oracledb::preinstalltasks':
    enabled       => $preinstalltasks,
    memory_target => $memory_target,
    manage_ntp    => $manage_ntp,
    manage_tmpfs  => $manage_tmpfs,
    ntp_servers   => $ntp_servers,
  }

  if($preinstallchecks)
  {
    class { 'oracledb::preinstallchecks':
      require => Class['oracledb::preinstalltasks'],
    }
  }



}
