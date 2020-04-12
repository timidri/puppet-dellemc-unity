# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'
require 'pry'

# Implementation for the job type using the Resource API.
class Puppet::Provider::Job::Job < Puppet::ResourceApi::SimpleProvider
  def get(context)
    context.debug('getting jobs')
    jobs = context.transport.jobs
    instances = []
    return instances if jobs.nil?

    jobs.each do |job|
      job = job['content']
      instances << {
        id:                 job['id'],
        description:        job['description'],
        state:              job['state'],
        progress_pct:       job['progressPct'],
        message_out:        job['messageOut'],
        affected_resource:  job['affectedResource'],
        client_data:        job['clientData'],
      }
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
