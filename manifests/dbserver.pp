group { 'puppet': ensure => 'present' }

class mysql_5 {
  
  exec { "update-package-list":
    command => "/usr/bin/sudo /usr/bin/apt-get update",
  }

  package { "mysql-server-5.1":
    ensure => present,
    require => Exec["update-package-list"],
  }
  
  service { "mysql":
    ensure => running, 
    require => Package["mysql-server-5.1"]
  }

  exec { "create-db-schema-and-user":
    command => "/usr/bin/mysql -uroot -p -e \"drop database if exists testapp; create database testapp; create user dbuser@'%' identified by 'dbuser'; grant all on testapp.* to dbuser@'%'; flush privileges;\"",
    require => Service["mysql"]
  }

  file { "/etc/mysql/my.cnf":
    owner => 'root',
    group => 'root',
    mode => 644,
    notify => Service['mysql'],
    source => '/vagrant/files/my.cnf',
    require => Package["mysql-server-5.1"],
  }

}

include mysql_5

