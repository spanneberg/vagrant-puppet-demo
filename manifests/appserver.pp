group { 'puppet': ensure => 'present' }

class sun_java_6 {

  $release = regsubst(generate("/usr/bin/lsb_release", "-s", "-c"), '(\w+)\s', '\1')

  # adds the partner repositry to apt
  file { "partner.list":
    path => "/etc/apt/sources.list.d/partner.list",
    ensure => file,
    owner => "root",
    group => "root",
    content => "deb http://archive.canonical.com/ $release partner\ndeb-src http://archive.canonical.com/ $release partner\n",
    notify => Exec["apt-get-update"],
  }

  exec { "apt-get-update":
    command => "/usr/bin/apt-get update",
    refreshonly => true,
  }

  package { "debconf-utils":
    ensure => installed
  }

  exec { "agree-to-jdk-license":
    command => "/bin/echo -e sun-java6-jdk shared/accepted-sun-dlj-v1-1 select true | debconf-set-selections",
    unless => "debconf-get-selections | grep 'sun-java6-jdk.*shared/accepted-sun-dlj-v1-1.*true'",
    path => ["/bin", "/usr/bin"], require => Package["debconf-utils"],
  }

  package { "sun-java6-jdk":
    ensure => latest,
    require => [ File["partner.list"], Exec["agree-to-jdk-license"], Exec["apt-get-update"] ],
  }

}

class tomcat_6 {
  package { "tomcat6":
    ensure => installed,
    require => Package['sun-java6-jdk'],
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

include sun_java_6
include tomcat_6

