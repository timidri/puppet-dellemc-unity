# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'

# Implementation for the unity_host type using the Resource API.
class Puppet::Provider::UnityNas::UnityNas < Puppet::ResourceApi::SimpleProvider
  def get(context)
    context.debug('getting nas servers')
    nass = context.transport.unity_get_collection('nasServer', context.transport.fields_for_type('nas'))
    instances = []
    return instances if nass.nil?

    nass.each do |nas|
      instance = {}
      context.type.attributes.each do |k, v|
        instance[k] = nas[v[:field_name]]
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
