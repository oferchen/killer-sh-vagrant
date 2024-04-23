# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 2.2.9"
require 'json'

def architecture_config
  host_arch = `uname -m`.chomp
  case host_arch
  when 'x86_64', 'amd64'
    { box_name: "ubuntu/focal64", provider_name: "virtualbox", disk_size: '50GB', required_plugins: ['','vagrant-disksize'] }
  when 'aarch64', 'arm64'
    { box_name: "bento/ubuntu-20.04", provider_name: "vmware_desktop", disk_size: nil, required_plugins: ['vagrant-vmware-desktop'] }
  else
    raise "Unsupported architecture: #{host_arch}"
  end
end

def find_default_interface
  os = RUBY_PLATFORM.include?("darwin") ? :macos : :linux
  case os
  when :linux
    `ip route | grep default | awk '{print $5}'`.strip
  when :macos
    `route -n get default | grep interface | awk '{print $2}'`.strip
  else
    raise "Unsupported operating system. This script supports only macOS and Linux."
  end
end

def check_plugins
  $arch_conf = architecture_config
  required_plugins = $arch_conf[:required_plugins]
  missing_plugins = required_plugins.select { |plugin| not Vagrant.has_plugin?(plugin) }
  if missing_plugins.any?
    raise Vagrant::Errors::VagrantError.new, "Missing plugins: #{missing_plugins.join(', ')}. Please install them and rerun 'vagrant up'."
  end
end

def configure_provider(provider, config)
  provider.memory = 4096
  provider.cpus = 4
  provider.gui = false
  provider.vmx["ethernet0.virtualdev"] = "vmxnet3" if config[:provider_name].include?("vmware")
end

def configure_network(node, ip)
  default_interface = find_default_interface
  node.vm.network :private_network, bridge: default_interface, ip: ip
  node.vm.network "forwarded_port", guest: 22, host: ip.split('.').last.to_i + 2700
end

def provision_node(node, role, ip)
  $arch_conf = architecture_config
  node.vm.box = $arch_conf[:box_name]
  node.vm.hostname = role
  configure_network(node, ip)

  if $arch_conf[:disk_size] && !$arch_conf[:provider_name].include?("vmware_desktop")
    node.vm.disk :disk, size: $arch_conf[:disk_size], primary: true
  end

  node.vm.provision "shell", path: "scripts/setup-etc-hosts.sh", args: [ip], privileged: true
  node.vm.provision "shell", path: "scripts/install-#{role}.sh", env: {"DEBIAN_FRONTEND" => "noninteractive", "INSTALL_SCRIPT" => $install_script }, privileged: true
  node.vm.provision "shell", reboot: true
end

$install_script = ENV['INSTALL_SCRIPT'] || "latest"
$enable_join = ENV['ENABLE_JOIN'].nil? ? true : ENV['ENABLE_JOIN'].downcase == 'true'
$arch_conf = architecture_config
check_plugins

Vagrant.configure("2") do |config|
  config.vm.box = $arch_conf[:box_name]
  config.vm.box_check_update = false

  config.vm.provider $arch_conf[:provider_name] do |provider|
    configure_provider(provider, $arch_conf)
  end

  nodes = {
    "cks-master" => "192.168.5.10",
    "cks-worker" => "192.168.5.20",
  }

  nodes.each do |role, ip|
    config.vm.define role do |node|
      provision_node(node, role, ip)
      if role.include?("worker") && $enable_join
        node.trigger.after :up do |trigger|
          trigger.info = "Joining worker to the cluster..."
          trigger.run = {path: "join-node.sh"}
        end
      end
    end
  end
end
