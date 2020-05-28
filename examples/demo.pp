class { 'oracledb':
  memlock_factor            => '0.95',
  sga_gb                    => '16',
  validate_resulting_values => false,
}
