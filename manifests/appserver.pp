group { 'puppet': ensure => 'present' }

# update the (outdated) package list
exec { "update-package-list":
  command => "/usr/bin/sudo /usr/bin/apt-get update",
}

class java_6 {

  package { "openjdk-6-jdk":
    ensure => installed,
    require => Exec["update-package-list"],
  }

}

class tomcat_6 {

  package { "tomcat6":
    ensure => installed,
    require => Package['openjdk-6-jdk'],
  }
  
  package { "tomcat6-admin":
    ensure => installed,
    require => Package['tomcat6'],
  }
  
  service { "tomcat6":
    ensure => running,
    require => Package['tomcat6'],
    subscribe => File["mysql-connector.jar", "tomcat-users.xml"]
  }

  file { "tomcat-users.xml":
    owner => 'root',
    path => '/etc/tomcat6/tomcat-users.xml',
    require => Package['tomcat6'],
    notify => Service['tomcat6'],
    content => template('/vagrant/templates/tomcat-users.xml.erb')
  }

  file { "mysql-connector.jar":
    require => Package['tomcat6'],
    owner => 'root',
    path => '/usr/share/tomcat6/lib/mysql-connector-java-5.1.15.jar',
    source => '/vagrant/files/mysql-connector-java-5.1.15.jar'
  }

}

# set variables
$tomcat_password = '12345'
$tomcat_user = 'tomcat-admin'

include java_6
include tomcat_6

