# -*- mode: ruby -*-
# vi: set ft=ruby :

# very slapdash vagrant config

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "blis"
  
  # forward http
  config.vm.network "forwarded_port", host: 62326, guest: 80
  
  # forward https
  config.vm.network "forwarded_port", host: 62443, guest: 443
  
  # forward mysql
  config.vm.network "forwarded_port", host: 3306, guest: 3306
  
  config.vm.provision "file", source: "vagrant/bootstrap/vagrant-blis-httpd-2.4.conf", destination: "/home/vagrant/vagrant-blis-httpd.conf"
  config.vm.provision "file", source: "vagrant/bootstrap/xdebug-trusty.ini", destination: "/home/vagrant/xdebug.ini"
  config.vm.provision "file", source: "vagrant/bootstrap/emptydb-20160520.sql", destination: "/home/vagrant/emptydb-20160520.sql"
  config.vm.provision "file", source: "vagrant/bootstrap/grant-privileges.sql", destination: "/home/vagrant/grant-privileges.sql"
  
  config.vm.provision :shell, :inline => "sudo apt-get update && apt-get -y upgrade", run: "once"
  config.vm.provision :shell, :inline => "sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/database-type    select  mysql'", run: "once" 
  config.vm.provision :shell, :inline => "sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2'", run: "once" 
  
  config.vm.provision :shell, :inline => "export DEBIAN_FRONTEND=noninteractive; sudo -E apt-get install -q -y apache2 php5 php5-xdebug mysql-server mysql-client php5-mysql libapache2-mod-auth-mysql phpmyadmin ssl-cert", run: "once"
  config.vm.provision :shell, :inline => "sudo a2enmod rewrite ssl", run: "once"
  config.vm.provision :shell, :inline => "sudo mv /home/vagrant/vagrant-blis-httpd.conf /etc/apache2/sites-available/vagrant-blis-httpd.conf", run: "once"
  config.vm.provision :shell, :inline => "sudo mv /home/vagrant/xdebug.ini /etc/php5/mods-available/xdebug.ini", run: "once"
  config.vm.provision :shell, :inline => "sudo sed -i 's/.*bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/my.cnf", run: "once"
  config.vm.provision :shell, :inline => "service mysql restart", run: "once"
  config.vm.provision :shell, :inline => "sudo rm -f /etc/apache2/sites-enabled/000-default.conf", run: "once"
  config.vm.provision :shell, :inline => "sudo ln -s /etc/apache2/sites-available/vagrant-blis-httpd.conf /etc/apache2/sites-enabled/", run: "once"
  config.vm.provision :shell, :inline => "mysql -u root </home/vagrant/grant-privileges.sql", run: "once"
  config.vm.provision :shell, :inline => "mysql -u root </home/vagrant/emptydb-20160520.sql", run: "once"
  config.vm.provision :shell, :inline => "rm /home/vagrant/emptydb-20160520.sql /home/vagrant/grant-privileges.sql", run: "once"
  config.vm.provision :shell, :inline => "sudo sed -i 's/\\s\\+\\/\\/\\(.*\\)AllowNoPassword\\(.*\\)/\\1AllowNoPassword\\2/' /etc/phpmyadmin/config.inc.php", run: "once"
  
  # do this last so that the /vagrant shared folder is mounted for apache logs
  config.vm.provision :shell, :inline => "service apache2 restart", run: "always"

  config.vm.provider "virtualbox" do |v|
	v.memory = 1024
	v.cpus = 2
  end
  config.ssh.insert_key = false
end
