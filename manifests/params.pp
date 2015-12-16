class oracledb::params {

  case $::osfamily
  {
    'redhat':
    {
      case $::operatingsystemrelease
      {
        /^7.*$/:
        {
          $oracledb_dependencies= [
                                    'binutils', 'glibc', 'libgcc', 'libstdc++',
                                    'libaio', 'libXext', 'libXtst', 'libX11',
                                    'libXau', 'libxcb', 'libXi', 'make',
                                    'sysstat', 'compat-libcap1',
                                    'compat-libstdc++-33', 'gcc', 'gcc-c++',
                                    'glibc-devel', 'ksh', 'libstdc++-devel',
                                    'libaio-devel', 'cpp',
                                    'kernel-headers',
                                    # 'cloog-ppl', 'ppl', 'twm',
                                    'mpfr', 'tigervnc-server',
                                    'xterm', 'xorg-x11-utils', 'nfs-utils' ]
        }
        default: { fail("Unsupported RHEL/CentOS version! - $::operatingsystemrelease")  }
      }

    }
    'Debian':
    {
      fail("Unsupported")
    }
    default: { fail("Unsupported OS!")  }
  }
}
