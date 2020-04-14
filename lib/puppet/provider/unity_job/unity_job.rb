# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'
require 'pry'

# Implementation for the job type using the Resource API.
class Puppet::Provider::UnityJob::UnityJob < Puppet::ResourceApi::SimpleProvider
  def get(context)
    context.debug('getting jobs')
    jobs = context.transport.unity_get_instances('job', context.type.attributes.values.map { |v| v[:field_name] })
    instances = []
    return instances if jobs.nil?

    jobs.each do |job|
      instance = {}
      context.type.attributes.each do |k, v|
        instance[k] = job['content'][v[:field_name]]
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
