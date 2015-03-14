require 'puppet/parameter/boolean'
Puppet::Type.newtype(:cumulus_bridge) do
  desc 'Config cumulus bridge interface'

  # helps set parameter type to integer`
  def munge_integer(value)
    Integer(value)
  rescue ArgumentError
    fail("munge_integer only takes integers")
  end

  def munge_array(value)
    return_value = value
    msg = 'should be array not comma separated string'
    if value.class == String
      raise ArgumentError, msg if value.include?(',')
      return_value = [value]
    end
    if value.class != Array
      raise ArgumentError 'should be array'
    end
    return_value
  end

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

  newparam(:ipv4) do
    desc 'list of ipv4 addresses
    ip address must be in CIDR format and subnet mask included
    Example: 10.1.1.1/30'
  end

  newparam(:ipv6) do
    desc 'list of ipv6 addresses
    ip address must be in CIDR format and subnet mask included
    Example: 10:1:1::1/127'
  end

  newparam(:alias_name) do
    desc 'interface description'
  end

  newparam(:addr_method) do
    desc 'address assignment method'
    newvalues(:dhcp)
  end

  newparam(:speed) do
    desc 'link speed in MB. Example "1000" means 1G'
    munge do |value|
      @resource.munge_integer(value)
    end
  end

  newparam(:mtu) do
    desc 'link mtu. Can be 1500 to 9000 KBs'
    munge do |value|
      @resource.munge_integer(value)
    end
  end

  newparam(:virtual_ip) do
    desc 'virtual IP component of Cumulus Linux VRR config'
  end

  newparam(:virtual_mac) do
    desc 'virtual MAC component of Cumulus Linux VRR config'
  end

  newparam(:vids) do
    desc 'list of vlans. Only configured on vlan aware ports'
    munge do |value|
      @resource.munge_array(value)
    end
  end

  newparam(:pvid) do
    desc 'vlan transmitted untagged across the link (native vlan)'
    munge do |value|
      @resource.munge_integer(value)
    end
  end

  newparam(:location) do
    desc 'location of interface files'
    defaultto '/etc/network/interfaces.d'
  end

  newparam(:stp, :boolean => true,
          :parent => Puppet::Parameter::Boolean) do
    desc 'enables spanning tree. default is "on" '
    defaultto true
  end

  newparam(:vlan_aware, :boolean => true,
          :parent => Puppet::Parameter::Boolean) do
    desc 'enables vlan aware mode. Selects between the classic bridge driver
    and vlan aware bridge driver. Only one bridge should be covered in vlan
    aware mode'
  end

  newparam(:ports) do
    desc 'list of bridge members'
    munge do |value|
      @resource.munge_array(value)
    end
  end

  newparam(:mstpctl_treeprio) do
    desc 'spanning tree root priority. Must be a multiple of 4096'
    munge do |value|
      @resource.munge_integer(value)
    end
  end

  validate do
    if self[:ports].nil?
      raise Puppet::Error, 'ports list required'
    end

    if self[:virtual_ip].nil? ^ self[:virtual_mac].nil?
      raise Puppet::Error, 'VRR parameters virtual_ip and virtual_mac must be
      configured together'
    end
  end
end
