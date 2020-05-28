class oracledb::users() inherits oracledb {

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  include ::pam

  pam::limit { 'memlock *':
    domain => '*',
    item   => 'memlock',
    value  => $oracle::limit_memlock_all_value,
  }

  exec { 'oracle ulimits':
    command => 'echo -e "\n\n\n#EYP-ORACLEDB SET ULIMIT\n\nif [ \$USER = \"oracle\" ]; then\n if [ $SHELL = \"/bin/ksh\" ]; then\n ulimit -p 16384\n ulimit -n 65536\n else\n ulimit -u 16384 -n 65536\n fi\nfi" >> /etc/profile',
    unless  => 'grep "EYP-ORACLEDB SET ULIMIT" /etc/profile';
  }

  #limits
  # oracle              soft    nproc    2047
  pam::limit { 'oracle soft nproc':
    domain => 'oracle',
    item   => 'nproc',
    value  => $oracledb::limit_soft_nproc_oracle,
    type   => 'soft',
  }

  # oracle              hard   nproc   16384
  pam::limit { 'oracle hard nproc':
    domain => 'oracle',
    item   => 'nproc',
    value  => $oracledb::limit_hard_nproc_oracle,
    type   => 'hard',
  }

  # oracle              soft    nofile    1024
  pam::limit { 'oracle soft nofile':
    domain => 'oracle',
    item   => 'nofile',
    value  => $oracledb::limit_soft_nofile_oracle,
    type   => 'soft',
  }

  # oracle              hard   nofile    65536
  pam::limit { 'oracle hard nofile':
    domain => 'oracle',
    item   => 'nofile',
    value  => $oracledb::limit_hard_nofile_oracle,
    type   => 'hard',
  }

  # oracle              soft    stack    10240
  # oracle              hard   stack    10240
  pam::limit { 'stack oracle':
    domain => 'oracle',
    item   => 'stack',
    value  => $oracledb::limit_stack_oracle,
  }

  # oracle              soft    core    4194304
  # oracle              hard    core    4194304
  pam::limit { 'core oracle':
    domain => 'oracle',
    item   => 'core',
    value  => $oracledb::limit_core_oracle,
  }

  if($oracledb::createoracleusers)
  {
    # # RDBMS groups
    # groupadd -g 10000 dba
    group { 'dba':
      ensure => present,
      gid    => '10000',
    }

    # groupadd -g 10001 oinstall
    group { 'oinstall':
      ensure => present,
      gid    => '10001',
    }

    # groupadd -g 10002 oper
    group { 'oper':
      ensure => present,
      gid    => '10002',
    }

    # # Users
    # adduser -u 10000 -g oinstall,oper -G dba -d /home/oracle -s /bin/bash -c "Oracle User" -m oracle
    # (01:25:24 PM) David Jimenez Perez: [root@rac12c1 ~]# id oracle
    # uid=10000(oracle) gid=10001(oinstall) groups=10000(dba),10002(oper),10001(oinstall)
    user { 'oracle':
      ensure     => present,
      shell      => '/bin/bash',
      gid        => 'oinstall',
      groups     => [ 'dba', 'oper' ],
      uid        => '10000',
      managehome => true,
      home       => '/home/oracle',
      comment    => 'Oracle User',
      require    => Group[ [ 'dba', 'oinstall', 'oper' ] ],
    }

    if($oracledb::griduser)
    {

      # # GI groups
      # groupadd  -g 502 asmadmin
      group { 'asmadmin':
        ensure => present,
        gid    => '502',
      }

      # groupadd -g 503 asmdba
      group { 'asmdba':
        ensure => present,
        gid    => '503',
      }

      # groupadd -g 504 asmoper
      group { 'asmoper':
        ensure => present,
        gid    => '504',
      }

      # # Users
      # adduser -u 501 -g oinstall -G dba,asmadmin,asmdba,asmoper -d /home/grid -s /bin/bash -c "GI User" -m grid
      user { 'grid':
        ensure     => present,
        shell      => '/bin/bash',
        gid        => 'oinstall',
        groups     => [ 'dba', 'asmadmin', 'asmdba', 'asmoper' ],
        uid        => '501',
        managehome => true,
        home       => '/home/grid',
        comment    => 'GI User', # Grid Infrastucture
        require    => Group[ [ 'asmadmin', 'asmdba', 'asmoper', 'dba' ] ],
      }

      #limits
      # grid  soft    nofile    1024
      pam::limit { 'grid soft nofile':
        domain => 'grid',
        item   => 'nofile',
        value  => $oracledb::limit_soft_nofile_grid,
        type   => 'soft',
      }

      # grid  hard  nofile  65536
      pam::limit { 'grid hard nofile':
        domain => 'grid',
        item   => 'nofile',
        value  => $oracledb::limit_hard_nofile_grid,
        type   => 'hard',
      }
    }
  }
}
