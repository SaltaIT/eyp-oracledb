class oracledb::preinstallchecks() inherits oracledb::params {

  $current_mode = $::selinux? {
		'false' => 'disabled',
		false   => 'disabled',
		default => $::selinux_current_mode,
	}

  if !(
        ($::eyp_grub2_kernel_cmdline!=undef) and
        ($::eyp_grub2_kernel_cmdline  =~ /transparent_hugepage=never/)
      )
  {
    fail('transparent_hugepage=never not present, reboot required nigga')
  }

  if($current_mode!='disabled')
  {
    fail('SELinux not disabled, reboot required nigga')
  }

  if($::fqdn !~ /(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\.)+[a-zA-Z]{2,63}$)/)
  {
    fail("As the point five of the environment section says (Requirements for Installing Oracle Database 12.1 on RHEL6 or OL6 64-bit (x86-64) (Doc ID 1529864.1)), host's name must be a FQDN")
  }
}
