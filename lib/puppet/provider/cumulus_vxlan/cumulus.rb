require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'cumulus', 'ifupdown2.rb'))
Puppet::Type.type(:cumulus_vxlan).provide :cumulus do
  confine :true => (Facter.value(:os)['name'] =~ /(?i)cumulus/)

  def build_desired_config
    config = Ifupdown2Config.new(resource)
    config.update_alias_name

    %w(access arp_nd_suppress learning).each do |attr|
      config.update_attr(attr, 'bridge')
    end

    %w(mstpctl_bpduguard mstpctl_portbpdufilter mtu
      vxlan_id vxlan_local_tunnelip
    ).each do |attr|
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
