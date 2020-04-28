# frozen_string_literal: true

require_relative '../unity_provider'

# Implementation for the unity_lun type using the Resource API.
class Puppet::Provider::UnityLun::UnityLun < Puppet::Provider::UnityProvider

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
