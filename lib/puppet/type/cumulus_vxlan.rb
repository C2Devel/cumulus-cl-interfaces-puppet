require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'cumulus', 'utils.rb'))
require 'set'
require 'puppet/parameter/boolean'
Puppet::Type.newtype(:cumulus_vxlan) do
  desc 'Configure VXLAN interfaces on Cumulus Linux'
  include Cumulus::Utils

  ensurable do
    newvalue(:outofsync) do
    end
    newvalue(:insync) do
      provider.update_config
    end
    def retrieve
      result = provider.config_changed?
      result ? :outofsync : :insync
    end

    defaultto do
      :insync
    end
  end

  newparam(:name) do
    desc 'interface name'
  end

  newparam(:alias_name) do
    desc 'interface description'
  end

  newparam(:mtu) do
    desc 'link mtu. Can be 1500 to 9000 KBs'
    munge do |value|
      @resource.munge_integer(value)
    end
  end

  newparam(:access) do
    desc 'For bridging, a type of port that is non-trunking. For dot1x,
          an IP source address or network that will be serviced. (An integer from 1 to 4094)'
    munge do |value|
      @resource.munge_integer(value)
    end
  end

  newparam(:arp_nd_suppress,) do
    desc 'ARP ND suppression'
    munge do |value|
      @resource.validate_on_off(value)
    end
  end

  newparam(:learning) do
    desc 'The bridge port learning flag'
    munge do |value|
      @resource.validate_on_off(value)
    end
  end

  newparam(:location) do
    desc 'location of interface files'
    defaultto '/etc/network/interfaces.d'
  end

  newparam(:mstpctl_portbpdufilter,
           boolean: true,
           parent: Puppet::Parameter::Boolean) do
    desc 'BPDU filter on a port'
  end

  newparam(:mstpctl_bpduguard,
           boolean: true,
           parent: Puppet::Parameter::Boolean) do
    desc 'Bridge Protocol Data Unit guard'
  end

  newparam(:vxlan_id) do
    desc 'VXLAN Identifier (An integer from 1 to 16777214)'
    munge do |value|
      @resource.munge_integer(value)
    end
  end

  newparam(:vxlan_local_tunnelip) do
    desc 'VXLAN local tunnel ip'
  end
end
