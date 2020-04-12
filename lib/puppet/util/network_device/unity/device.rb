require 'puppet'
require 'puppet/resource_api/transport/wrapper'
# force registering the transport schema
require 'puppet/transport/schema/unity'

module Puppet::Util::NetworkDevice::Unity
  class Device < Puppet::ResourceApi::Transport::Wrapper
    def initialize(url_or_config, _options = {})
      super('unity', url_or_config)
    end
  end
end
