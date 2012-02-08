# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  
  # base box and URL where to get it if not present
  config.vm.box = "lucid64"
  config.vm.box_url = "http://files.vagrantup.com/lucid64.box"

  # config for the appserver box
  config.vm.define "appserver" do |app|
    app.vm.boot_mode = :gui
    app.vm.network "33.33.33.10"
    app.vm.host_name = "appserver01.local"
    app.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file = "appserver.pp"
    end
  end

  # config for the dbserver box
  config.vm.define "dbserver" do |db|
    db.vm.boot_mode = :gui
    db.vm.network "33.33.33.11"
    db.vm.host_name = "dbserver01.local"
    db.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file = "dbserver.pp"
    end
  end

end
