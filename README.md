# oracledb

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What oracledb affects](#what-oracledb-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with oracledb](#beginning-with-oracledb)
4. [Usage](#usage)
5. [Reference](#reference)
5. [Limitations](#limitations)
6. [Development](#development)
    * [Contributing](#contributing)
## Overview

OracleDB installation

## Module Description

intended to install OracleDB (it actually does not install oracle, just sets prerequisites)

## Setup

### What oracledb affects

* creates oracle and, optionally, grid users
* this module is a ROLE thus uses other modules to achive it's goals
  * eyp/ntp
  * eyp/firewalld
  * eyp/tuned
  * eyp/grub2
  * eyp/chronyd
  * eyp/nscd
  * eyp/epel
  * eyp/selinux
  * eyp/limits
  * eyp/sysctl
    * **WARNING**: some sysctl settings are automatically calculated using system's memory, on a shared server it might hurt performace or trigger OOM-killer

### Setup Requirements

This module requires pluginsync enabled

### Beginning with oracledb



## Usage

```puppet
class { 'oracledb':
  memory_target => '550M',
}
```

## Reference

### oracledb

* **memory_target** (default: 1G)
* **manage_ntp**        = true,
* **manage_tmpfs**      = true,
* **ntp_servers**       = undef,
* **preinstalltasks**   = true,
* **createoracleusers** = true,
* **griduser**          = true,
* **preinstallchecks**  = true,

## Limitations

Tested on CentOS 7 only

## Development

We are pushing to have acceptance testing in place, so any new feature should
have some test to check both presence and absence of any feature

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
