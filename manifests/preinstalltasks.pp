class oracledb::preinstalltasks (
                                  $memory_target,
                                  $enabled=true,
                                  $manage_ntp=true,
                                  $ntp_servers=undef,
                                  $manage_tmpfs=true,
                                ) inherits oracledb::params {

  if($enabled)
  {
    class { 'epel': }

    package { $oracledb_dependencies:
      ensure => 'installed',
      require => Class['epel'],
    }

    #firewalld
    class { 'firewalld':
      ensure => 'masked',
    }

    class { 'chronyd':
      ensure => 'masked',
    }

    class { 'nscd': }

    class { 'selinux':
      mode => 'disabled',
    }

    class { 'grub2':
      transparent_huge_pages => 'never',
    }

    class { 'tuned': }

    tuned::profile { 'oracledb':
      enable  => true,
      vm      => { 'transparent_huge_pages' => 'never' },
      sysctl  => {
                    'vm.swappiness'                => '0',
                    'vm.dirty_background_ratio'    => '3',
                    'vm.dirty_ratio'               => '15',
                    'vm.dirty_expire_centisecs'    => '500',
                    'vm.dirty_writeback_centisecs' => '100',
                    'kernel.randomize_va_space'    => '0',
                    'kernel.sem'                   => '250 32000 100 128',
                  },
      require => Class['tuned'],
    }

    $current_mode = $::selinux? {
      'false' => 'disabled',
      false   => 'disabled',
      default => $::selinux_current_mode,
    }

    # Configure tempfs space
    #
    # You have to have a temporary filesystem with a configured that equals (at least) your memory_target parameter. In order to reconfigure the available space on this filesystem do the following:
    # [root@oracle12c ~]# mount -o remount,size=2200m /dev/shm/
    #
    # To make it permanent do the following:
    # [root@oracle12c ~]# vi /etc/fstab
    # ...
    # tmpfs                   /dev/shm                tmpfs   defaults,size=2200m        0 0
    # ...
    mount { '/dev/shm':
      ensure   => mounted,
      device   => "none",
      fstype   => 'tmpfs',
      options  => "size=${memory_target}",
    }



    # Configure ntpd service
    #
    # Start ntpd service and make sure it will be started after rebooting:
    # [root@oracle12casm ~]# vi /etc/sysconfig/ntpd
    # ...
    # OPTIONS="-x -g"
    # ...
    # [root@oracle12casm ~]# systemctl enable ntpd
    # [root@oracle12casm ~]# systemctl start ntpd
    if($manage_ntp)
    {
      class { 'ntp':
        servers => $ntp_servers,
      }
    }

  }

}
