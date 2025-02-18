require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'cumulus', 'ifupdown2.rb'))
Puppet::Type.type(:cumulus_interface).provide :cumulus do
  confine :true => (Facter.value(:os)['name'] =~ /(?i)cumulus/)

  def build_desired_config
    config = Ifupdown2Config.new(resource)
    config.update_speed
    config.update_addr_method
    config.update_address
    %w(access allow_untagged vids pvid).each do |attr|
      config.update_attr(attr, 'bridge')
    end
    config.update_alias_name
    config.update_vrr
    config.update_up
    config.update_down
    # attributes with no suffix like bond-, or bridge-
    %w(mstpctl_portnetwork mstpctl_bpduguard mstpctl_portadminedge clagd_enable clagd_priority
       clagd_backup_ip clagd_args clagd_sys_mac clagd_peer_ip clagd_vxlan_anycast_ip
       mtu gateway vlan_raw_device vlan_id vrf vrf_table).each do |attr|
      config.update_attr(attr)
    end
    # copy to instance variable
    @config = config
  end

  def config_changed?
    build_desired_config
    Puppet.debug "desired config #{@config.confighash}"
    Puppet.debug "current config #{@config.currenthash}"
    ! @config.compare_with_current
  end

  def update_config
    @config.write_config
  end
end
