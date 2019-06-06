class oracledb::preinstalltasks inherits oracledb {

  if($oracledb::preinstalltasks)
  {
    include ::epel

    package { $oracledb::params::oracledb_dependencies:
      ensure  => 'installed',
      require => Class['epel'],
    }

    #firewalld
    include ::firewalld

    class { 'chronyd':
      ensure => 'masked',
    }

    include ::nscd

    include ::selinux

    if($oracledb::manage_grub)
    {
      class { 'grub2':
        transparent_huge_pages => 'never',
      }
    }

    include ::tuned

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
      value => $oracledb::sysctl_vm_swappiness,
    }

    sysctl::set { 'vm.dirty_background_ratio':
      value => $oracledb::sysctl_vm_dirty_background_ratio,
    }

    sysctl::set { 'vm.dirty_ratio':
      value => $oracledb::sysctl_vm_dirty_ratio,
    }

    sysctl::set { 'vm.dirty_expire_centisecs':
      value => $oracledb::sysctl_vm_dirty_expire_centisecs,
    }

    sysctl::set { 'vm.dirty_writeback_centisecs':
      value => $oracledb::sysctl_vm_dirty_writeback_centisecs,
    }

    sysctl::set { 'kernel.randomize_va_space':
      value => $oracledb::sysctl_kernel_randomize_va_space,
    }

    sysctl::set { 'kernel.sem':
      value => $oracledb::kernel_sem,
    }

    if($::memorysize_mb>=16384)
    {
      # mes de 16G
      # shmmax = 50% de la memoria total en bytes

      # shmall = shmmax/kernel.shmmni

      sysctl::set { 'kernel.shmmax':
        value => $oracledb::sysctl_kernel_shmmax,
      }

      if($oracledb::kernel_shmall!=undef)
      {
        $kernel_shmall_value = $oracledb::kernel_shmall
      }
      else
      {
        $kernel_shmall_value = ceiling(ceiling(sprintf('%f', $::memorysize_mb)*786432)/4096)
      }

      sysctl::set { 'kernel.shmall':
        value => $kernel_shmall_value,
      }
    }
    else
    {
      # menys de 16G
      # shmmax = 50% de la memoria total en bytes

      # shmall = shmmax/kernel.shmmni

      if($oracledb::kernel_shmmax!=undef)
      {
        $kernel_shmmax_value = $oracledb::kernel_shmmax
      }
      else
      {
        $kernel_shmmax_value = ceiling(sprintf('%f', $::memorysize_mb)*524288)
      }

      sysctl::set { 'kernel.shmmax':
        value => $kernel_shmmax_value,
      }

      sysctl::set { 'kernel.shmall':
        value => ceiling(ceiling(sprintf('%f', $::memorysize_mb)*524288)/4096),
      }
    }

    # kernel.shmmni        =      4096

    sysctl::set { 'kernel.shmmni':
      value => $oracledb::kernel_shmmni,
    }


    # kernel.panic_on_oops  =   1

    sysctl::set { 'kernel.panic_on_oops':
      value => $oracledb::sysctl_kernel_panic_on_oops,
    }

    # fs.file-max        =      6815744

    sysctl::set { 'fs.file-max':
      value => $oracledb::fs_file_max,
    }

    # fs.aio-max-nr      =    1048576

    sysctl::set { 'fs.aio-max-nr':
      value => $oracledb::fs_aio_max_nr,
    }

    # net.core.rmem_default    =     262144

    sysctl::set { 'net.core.rmem_default':
      value => $oracledb::sysctl_net_core_rmem_default,
    }

    # net.core.rmem_max        =    4194304

    sysctl::set { 'net.core.rmem_max':
      value => $oracledb::sysctl_net_core_rmem_max,
    }

    # net.core.wmem_default    =    262144

    sysctl::set { 'net.core.wmem_default':
      value => $oracledb::sysctl_net_core_wmem_default,
    }

    # net.core.wmem_max        =   1048576

    sysctl::set { 'net.core.wmem_max':
      value => $oracledb::sysctl_net_core_wmem_max,
    }

    # kernel.hostname =  hostname

    # sysctl::set { 'kernel.hostname':
    #   value => $::fqdn,
    # }

    # vm.nr_hugepages= (60% memoria total en MB / 2) +2

    sysctl::set { 'vm.nr_hugepages':
      value => $oracledb::sysctl_vm_nr_hugepages,
    }

    # net.ipv4.ip_local_port_range = 9000 65500

    sysctl::set { 'net.ipv4.ip_local_port_range':
      value => $oracledb::net_ipv4_ip_local_port_range,
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
    if($oracledb::manage_tmpfs)
    {
      if(defined(Mount['/dev/shm']))
      {
        $shm_options=getparam(Mount['/dev/shm'], 'options')

        File <| title == '/dev/shm' |> {
          options => "${shm_options},size=${oracledb::memory_target}",
        }
        #
        # Mount['/dev/shm'] {
        #   options => "${shm_options},size=${memory_target}",
        # }
      }
      else
      {
        mount { '/dev/shm':
          ensure  => 'mounted',
          device  => 'tmpfs',
          fstype  => 'tmpfs',
          options => "size=${oracledb::memory_target}",
        }

        if($oracledb::add_stage)
        {
          Mount['/dev/shm'] {
            stage => 'eyp-oracle-db',
          }
        }
      }
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
    if($oracledb::manage_ntp)
    {
      class { 'ntp':
        servers => $oracledb::ntp_servers,
      }
    }

  }

}
