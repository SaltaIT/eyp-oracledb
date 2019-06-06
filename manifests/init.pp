class oracledb(
                $memory_target                       = '1G',
                $manage_ntp                          = true,
                $manage_grub                         = true,
                $manage_tmpfs                        = true,
                $ntp_servers                         = undef,
                $preinstallchecks                    = true,
                $add_stage                           = true,
                $fs_file_max                         = '6815744',
                $net_ipv4_ip_local_port_range        = "9000\t65500",
                $kernel_sem                          = "250\t32000\t100\t128",
                $kernel_shmmni                       = '4096',
                $kernel_shmall                       = undef,
                $kernel_shmmax                       = undef,
                # preuinstall tasks
                $preinstalltasks                     = true,
                $fs_aio_max_nr                       = '1048576',
                #sysctl
                $sysctl_vm_swappiness                = '0',
                $sysctl_vm_dirty_background_ratio    = '3',
                $sysctl_vm_dirty_ratio               = '15',
                $sysctl_vm_dirty_expire_centisecs    = '500',
                $sysctl_vm_dirty_writeback_centisecs = '100',
                $sysctl_kernel_randomize_va_space    = '0',
                $sysctl_kernel_panic_on_oops         = '1',
                $sysctl_net_core_rmem_default        = '262144',
                $sysctl_net_core_rmem_max            = '4194304',
                $sysctl_net_core_wmem_default        = '262144',
                $sysctl_net_core_wmem_max            = '1048576',
                $sysctl_kernel_shmmax                = ceiling(sprintf('%f', $::memorysize_mb)*786432),
                $sysctl_vm_nr_hugepages              = ceiling(sprintf('%f', $::memorysize_mb)*0.3)+2,
                #users
                $griduser                            = true,
                $createoracleusers                   = true,
                $limit_soft_nofile_oracle            = '1024',
                $limit_hard_nofile_oracle            = '65536',
                $limit_soft_nproc_oracle             = '2047',
                $limit_hard_nproc_oracle             = '16384',
                $limit_core_oracle                   = '4194304',
                $limit_stack_oracle                  = '10240',
                $limit_soft_nofile_grid              = '1024',
                $limit_hard_nofile_grid              = '65536',
                #
                $memlock                             = ceiling(sprintf('%f', $::memorysize_mb)*921.6),
              ) inherits oracledb::params {

  if($add_stage)
  {
    stage { 'eyp-oracle-db': }

    Stage['main'] -> Stage['eyp-oracle-db']

    Class['::oracledb::users'] {
      stage => 'eyp-oracle-db',
    }
  }

  class { '::oracledb::users': }

  ->

  class { 'oracledb::preinstalltasks': }

  if($preinstallchecks)
  {
    class { 'oracledb::preinstallchecks':
      require => Class['oracledb::preinstalltasks'],
    }
  }
}
