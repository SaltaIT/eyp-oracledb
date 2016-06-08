class oracledb::preinstalltasks (
                                  $memory_target = '1G',
                                  $enabled       = true,
                                  $manage_ntp    = true,
                                  $ntp_servers   = undef,
                                  $manage_tmpfs  = true,
                                ) inherits oracledb::params {

  if($enabled)
  {
    include ::epel

    package { $oracledb_dependencies:
      ensure  => 'installed',
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

    include ::selinux

    class { 'grub2':
      transparent_huge_pages => 'never',
    }

    class { 'tuned': }

    tuned::profile { 'oracledb':
      enable  => true,
      vm      => { 'transparent_huge_pages' => 'never' },
      # sysctl  => {
      #               'vm.swappiness'                => '0',
      #               'vm.dirty_background_ratio'    => '3',
      #               'vm.dirty_ratio'               => '15',
      #               'vm.dirty_expire_centisecs'    => '500',
      #               'vm.dirty_writeback_centisecs' => '100',
      #               'kernel.randomize_va_space'    => '0',
      #               'kernel.sem'                   => '250 32000 100 128',
      #             },
      require => Class['tuned'],
    }

    include ::sysctl

    sysctl::set { 'vm.swappiness':
      value => '0',
    }

    sysctl::set { 'vm.dirty_background_ratio':
      value => '3',
    }

    sysctl::set { 'vm.dirty_ratio':
      value => '15',
    }

    sysctl::set { 'vm.dirty_expire_centisecs':
      value => '500',
    }

    sysctl::set { 'vm.dirty_writeback_centisecs':
      value => '100',
    }

    sysctl::set { 'kernel.randomize_va_space':
      value => '0',
    }

    sysctl::set { 'kernel.sem':
      value => "250\t32000\t100\t128",
    }

    # shmmax = 50% de la memoria total en bytes

    sysctl::set { 'kernel.shmmax':
      value => ceiling(sprintf('%f', $::memorysize_mb)*524288),
    }

    # kernel.shmmni        =      4096

    sysctl::set { 'kernel.shmmni':
      value => '4096',
    }

    # shmall = shmmax/kernel.shmmni

    sysctl::set { 'kernel.shmall':
      value => ceiling(ceiling(sprintf('%f', $::memorysize_mb)*524288)/4096),
    }

    # kernel.panic_on_oops  =   1

    sysctl::set { 'kernel.panic_on_oops':
      value => '1',
    }

    # fs.file-max        =      6815744

    sysctl::set { 'fs.file-max':
      value => '6815744',
    }

    # fs.aio-max-nr      =    1048576

    sysctl::set { 'fs.aio-max-nr':
      value => '1048576',
    }

    # net.core.rmem_default    =     262144

    sysctl::set { 'net.core.rmem_default':
      value => '262144',
    }

    # net.core.rmem_max        =    4194304

    sysctl::set { 'net.core.rmem_max':
      value => '4194304',
    }

    # net.core.wmem_default    =    262144

    sysctl::set { 'net.core.wmem_default':
      value => '262144',
    }

    # net.core.wmem_max        =   1048576

    sysctl::set { 'net.core.wmem_max':
      value => '1048576',
    }

    # kernel.hostname =  hostname

    # sysctl::set { 'kernel.hostname':
    #   value => $::fqdn,
    # }

    # vm.nr_hugepages= (60% memoria total en MB / 2) +2

    sysctl::set { 'vm.nr_hugepages':
      value => ceiling(sprintf('%f', $::memorysize_mb)*0.3)+2,
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
      ensure  => mounted,
      device  => 'none',
      fstype  => 'tmpfs',
      options => "size=${memory_target}",
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
