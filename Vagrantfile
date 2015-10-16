$setup = <<SCRIPT
  sed -i 's/http.us.debian/ftp.de.debian/g' /etc/apt/sources.list
  sed -i 's/http.us.archive/ftp.de.archive/g' /etc/apt/sources.list
  sed -i 's/us.archive.ubuntu.com/de.archive.ubuntu.com/g' /etc/apt/sources.list
  apt-get -o Acquire::Check-Valid-Until=false update --fix-missing >/dev/null
  echo 'Europe/Berlin' | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata >/dev/null
SCRIPT

$mageteststand = <<SCRIPT
  export SKIP_CLEANUP=true
  export WORKSPACE="/vagrant"
  export MAGENTO_VERSION="magento-mirror-1.9.2.1"
  export MAGENTO_DB_HOST="127.0.0.1"
  export MAGENTO_DB_PORT="3306"
  export MAGENTO_DB_USER="root"
  export MAGENTO_DB_PASS="mageteststand"
  export MAGENTO_DB_NAME="mageteststand"
  curl -sSL https://raw.githubusercontent.com/ffuenf/MageTestStand/master/setup.sh | bash
SCRIPT

Vagrant.configure('2') do |config|
  # vagrant-omnibus
  if Vagrant.has_plugin?('vagrant-omnibus')
    config.omnibus.chef_version = :latest
    config.omnibus.cache_packages = true
  end

  # vagrant-berkshelf
  config.berkshelf.berksfile_path = 'Berksfile' if Vagrant.has_plugin?('vagrant-berkshelf')
  config.berkshelf.enabled = true if Vagrant.has_plugin?('vagrant-berkshelf')

  # vagrant-cachier
  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :machine
    config.cache.synced_folder_opts = {
      type: :nfs,
      mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
    }
  end

  # network
  config.vm.network 'private_network', ip: '10.0.0.50'

  # basebox
  config.vm.box = 'ffuenf/debian-7.9.0-amd64'

  # virtualbox options
  config.vm.provider 'virtualbox' do |v|
    v.gui = false
    v.customize ['modifyvm', :id, '--memory', 2048]
    v.customize ['modifyvm', :id, '--cpus', 2]
    v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    v.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
  end

  # setup
  config.vm.provision 'shell', inline: $setup

  # chef
  config.vm.provision 'chef_zero' do |chef|
    chef.provisioning_path = '/tmp/vagrant-chef-solo'
    chef.file_cache_path = chef.provisioning_path
    chef.cookbooks_path = ['.']
    chef.add_recipe 'mageteststand'
    chef.json = {
      "php" => {
        "xdebug" => {
          "cli" => {
            "enabled" => "true"
          }
        }
      },
      "dotdeb" => {
        "php_version" => "5.6"
      },
      "redisio" => {
        "version" => "3.0.4",
        "checksum" => "a35e90ad581925134aa0fc92e969cc825f5cdee8e13c36a87d4d6995316112cf",
        "safe_install" => false
      },
      "mysql" => {
        "version" => "5.6",
        "bind_address" => "127.0.0.1",
        "port" => "3306",
        "server_root_password" => "mageteststand"
      }
    }
  end
  config.vm.provision 'shell', inline: $mageteststand
end
