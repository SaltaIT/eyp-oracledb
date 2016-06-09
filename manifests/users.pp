class oracledb::users (
                      $griduser          = false,
                      $createoracleusers = true,
                      $memlock           = ceiling(sprintf('%f', $::memorysize_mb)*921.6),
                      ) inherits oracledb::params {

  if($memlock!=undef)
  {
    #Hugepages
    # * soft memlock 90% total memoria en KB
    # * hard memlock 90% total memoria en KB

    limits::limit { 'memlock *':
      domain => '*',
      item   => 'memlock',
      value  => $memlock,
    }
  }

  #limits
  # oracle              soft    nproc    2047
  limits::limit { 'oracle soft nproc':
    domain => 'oracle',
    item   => 'nproc',
    value  => '2047',
    type   => 'soft',
  }

  # oracle              hard   nproc   16384
  limits::limit { 'oracle hard nproc':
    domain => 'oracle',
    item   => 'nproc',
    value  => '16384',
    type   => 'hard',
  }

  # oracle              soft    nofile    1024
  limits::limit { 'oracle soft nofile':
    domain => 'oracle',
    item   => 'nofile',
    value  => '1024',
    type   => 'soft',
  }

  # oracle              hard   nofile    65536
  limits::limit { 'oracle hard nofile':
    domain => 'oracle',
    item   => 'nofile',
    value  => '65536',
    type   => 'hard',
  }

  # oracle              soft    stack    10240
  # oracle              hard   stack    10240
  limits::limit { 'stack oracle':
    domain => 'oracle',
    item   => 'stack',
    value  => '10240',
  }

  # oracle              soft    core    4194304
  # oracle              hard    core    4194304
  limits::limit { 'core oracle':
    domain => 'oracle',
    item   => 'core',
    value  => '4194304',
  }

  if($createoracleusers)
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

    if($griduser)
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
      limits::limit { 'grid soft nofile':
        domain => 'grid',
        item   => 'nofile',
        value  => '1024',
        type   => 'soft',
      }

      # grid  hard  nofile  65536
      limits::limit { 'grid hard nofile':
        domain => 'grid',
        item   => 'nofile',
        value  => '65536',
        type   => 'hard',
      }

    }
  }
}
