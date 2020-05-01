# frozen_string_literal: true

require_relative '../unity_provider'

# Implementation for the unity_lun type using the Resource API.
class Puppet::Provider::UnityLun::UnityLun < Puppet::Provider::UnityProvider


  def body_from_should(context, should, prune_init_only=false) 
    body = {}
    attrs = context.type.attributes
    should.each do |k,v|
      next if [:ensure, :pool, :size_total, :is_thin_enabled].include? k
      next if prune_init_only && attrs[k][:behaviour] == :init_only
      body[attrs[k][:field_name]] = v 
    end
    body[:lunParameters] = {
        size: should[:size_total],
      }
    # require 'pry';binding.pry

    if ! prune_init_only
      body[:lunParameters][:pool] = should[:pool]
      body[:lunParameters][:isThinEnabled] = should[:is_thin_enabled]
    end

    body
  end

end
