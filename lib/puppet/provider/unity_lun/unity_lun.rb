# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'

# Implementation for the unity_lun type using the Resource API.
class Puppet::Provider::UnityLun::UnityLun < Puppet::ResourceApi::SimpleProvider
  def get(context)
    context.debug('getting luns')
    luns = context.transport.get_luns
    instances = []
    return instances if luns.nil?

    luns.each do |lun|
      instance = {}
      context.type.attributes.each do |k, v|
        instance[k] = lun['content'][v[:field_name]]
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
