class oracledb(
                $memory_target                       = '1G',
                $manage_ntp                          = true,
                $manage_grub                         = true,
                $manage_tmpfs                        = true,
                $ntp_servers                         = undef,
                $preinstallchecks                    = true,
                $fs_file_max                         = '6815744',
                $net_ipv4_ip_local_port_range        = "9000\t65500",
                $kernel_sem                          = "250\t32000\t100\t128",
                #kernel.shmmal                       = kernel.shmmax/kernel.shmmni
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
                $limit_soft_memlock_all              = ceiling(sprintf('%f', $::memorysize_mb)*972.8),
                $limit_hard_memlock_all              = ceiling(sprintf('%f', $::memorysize_mb)*972.8),
                #
                $memlock_factor                      = 0.95,
                $sga_gb                              = 16,
                $sysctl_kernel_shmmax                = undef,
                $sysctl_kernel_shmmni                = undef,
                $sysctl_kernel_shmall                = undef,
                $sysctl_vm_nr_hugepages              = undef,
              ) inherits oracledb::params {


  # * soft memlock XXXXXXXX
  # * hard memlock XXXXXXXX
  #
  # Value in KB 95% of physical RAM
  #
  # 1024*0.95 = 972.8

  if($memlock_factor > 1)
  {
    fail('memlock factor is greather than 1, should be between 0 and 1')
  }

  $memlock_calc = 1024*$memlock_factor
  $limit_memlock_all = ceiling(sprintf('%f', $::memorysize_mb)*$memlock_calc),

  # /etc/sysct.conf
  #
  # DBA team needs to provide the value of total SGA in one instances or two or necessary and DBA needs to consider the SGA of MGMDB
  #
  # kernel.shmmax = will be the same size of total SGA in bytes
  #
  # Restrictions never will be more than physical ram
  #
  # Normally sysctl_kernel_shmmni is 4096
  #
  # kernel.shmmal= kernel.shmmax/sysctl_kernel_shmmni (in pages)
  #
  # vm.nr_hugepages = Total SGA in GB * 1024 / 2MB +2
  # 20GB * 1024 = 20480MB / 2MB (Hugepagesize) = 10240 Hugepages +2

  $sysctl_kernel_shmmni_value = $sysctl_kernel_shmmni
  $sga_mb = $sga_gb*1024

  if($sga_mb>$::memorysize_mb)
  {
    fail("SGA cannot be larger than the physical RAM: ${sga_mb} vs ${::memorysize_mb}")
  }

  if($sysctl_kernel_shmmni==undef)
  {
    $sysctl_kernel_shmmni_value = 4096
  }
  else
  {
    $sysctl_kernel_shmmni_value = $sysctl_kernel_shmmni
  }

  if $sysctl_vm_nr_hugepages==undef)
  {
    $sysctl_vm_nr_hugepages_value_pre=$sga_mb/2
    $sysctl_vm_nr_hugepages_value=ceiling(sprintf('%f', $sysctl_vm_nr_hugepages_value_pre+2))
  }
  else
  {
    $sysctl_vm_nr_hugepages_value=$sysctl_vm_nr_hugepages
  }

  if($sysctl_kernel_shmmax==undef)
  {
    $sysctl_kernel_shmmax_value=ceiling(sprintf('%f', $sga_mb))
  }
  else
  {
    $sysctl_kernel_shmmax_value=$sysctl_kernel_shmmax
  }

  if($sysctl_kernel_shmall==undef)
  {
    $sysctl_kernel_shmall_value=ceiling(sprintf('%f', $sysctl_kernel_shmmax_value/$sysctl_kernel_shmmni_value))
  }
  else
  {
    $sysctl_kernel_shmall_value=$sysctl_kernel_shmall
  }


  class { '::oracledb::users':
  }

  ->

  class { 'oracledb::preinstalltasks': }

  if($preinstallchecks)
  {
    class { 'oracledb::preinstallchecks':
      require => Class['oracledb::preinstalltasks'],
    }
  }
}
