# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'

# Implementation for the unity_host type using the Resource API.
class Puppet::Provider::UnityHost::UnityHost < Puppet::ResourceApi::SimpleProvider
  def get(context)
    context.debug('getting jobs')
    hosts = context.transport.unity_get_instances('host', context.type.attributes.values.map { |v| v[:field_name] })
    instances = []
    return instances if hosts.nil?

    hosts.each do |host|
      instance = {}
      context.type.attributes.each do |k, v|
        instance[k] = host['content'][v[:field_name]]
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
