# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'

# Implementation for the unity_host type using the Resource API.
class Puppet::Provider::UnityPool::UnityPool < Puppet::ResourceApi::SimpleProvider
  def get(context)
    context.debug('getting storage pools')
    pools = context.transport.unity_get_collection('pool')
    instances = []
    return instances if pools.nil?

    pools.each do |pool|
      instance = {}
      context.type.attributes.each do |k, v|
        instance[k] = pool[v[:field_name]]
      end
      instances << instance
    end

    instances
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")
  end

  def delete(context, name)
    context.notice("Deleting '#{name}'")
  end
end
