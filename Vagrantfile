# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 2.2.9"
require 'json'

def architecture_config
  host_arch = `uname -m`.chomp

  case host_arch
  when 'x86_64', 'amd64'
    { box_name: "ubuntu/focal64", provider_name: "virtualbox" }
  when 'aarch64', 'arm64'
    { box_name: "bento/ubuntu-20.04", provider_name: "vmware_desktop" }
  else
    raise "Unsupported architecture: #{host_arch}"
  end
end

def find_default_interface
  os = RUBY_PLATFORM.include?("darwin") ? :macos : :linux
  case os
  when :linux
    # This is usually 'eth0' on Linux or whatever the default interface is on the host
    `ip route | grep default | awk '{print $5}'`.strip
  when :macos
    # This is usually 'en0: Wi-Fi (AirPort)' on a Macbook
    `route -n get default | grep interface | awk '{print $2}'`.strip
  else
    raise "Unsupported operating system. This script supports only macOS and Linux."
  end
end

def check_plugins
  required_plugins = ["vagrant-disksize"]
  missing_plugins = required_plugins.select { |plugin| not Vagrant.has_plugin?(plugin) }
  if missing_plugins.any?
    raise Vagrant::Errors::VagrantError.new, "Missing plugins: #{missing_plugins.join(', ')}. Please install them and rerun 'vagrant up'."
  end
end

def configure_provider(node, provider_name, vm_name, memory: 4096, cpus: 4, gui: false)
  node.vm.provider provider_name do |provider|
    case provider_name
      when "virtualbox"
        provider.name = vm_name.gsub('-', '_')
      when /vmware/
        provider.vmx["displayName"] = vm_name.gsub('-', '_')
      end
    provider.memory = memory
    provider.cpus = cpus
    provider.gui = gui
    provider.vmx["ethernet0.virtualdev"] = "vmxnet3" if provider_name.include?("vmware")
  end
end

def configure_network(node, ip)
  default_interface = find_default_interface
  node.vm.network :private_network, bridge: default_interface, ip: ip
  node.vm.network "forwarded_port", guest: 22, host: ip.split('.').last.to_i + 2700
end

def provision_node(node, role, ip)
  configure_provider(node, $arch_conf[:provider_name], "#{role}")
  node.vm.hostname = "#{role}"
  configure_network(node, ip)
  node.vm.provision "setup-etc-hosts", type: "shell", privileged: true, path: "scripts/setup-etc-hosts.sh", args: [ip]
  node.vm.provision "install-#{role}", type: "shell", privileged: true, env: {"DEBIAN_FRONTEND" => "noninteractive", "INSTALL_SCRIPT" => $install_script}, path: "scripts/install-#{role}.sh"
  node.vm.provision 'shell', reboot: true
end

$install_script = ENV['INSTALL_SCRIPT'] || "latest"
$enable_join = ENV['ENABLE_JOIN'].nil? ? true : ENV['ENABLE_JOIN'].downcase == 'true'
$arch_conf = architecture_config
check_plugins

Vagrant.configure("2") do |config|
  config.vm.box = $arch_conf[:box_name]
  config.disksize.size = '50GB'
  config.vm.box_check_update = false

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
