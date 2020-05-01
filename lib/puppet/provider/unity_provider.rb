require 'puppet/resource_api/simple_provider'

# A base provider for all PANOS providers
class Puppet::Provider::UnityProvider < Puppet::ResourceApi::SimpleProvider

  def set(context, changes)
    @changes = changes
    super.set(context, changes)
  end

  def get(context)
    # get unity resource type name from the type definition
    unity_resource_type = context.type.definition[:unity_resource_type]
    context.debug("getting #{unity_resource_type} collection")
    # require pry;binding.pry
    # get the Unity fields from the type definition
    fields = context.transport.fields_for_type(context.type.name)
    collection = context.transport.unity_get_collection(unity_resource_type, fields)

    instances = []
    return instances if collection.nil?

    collection.each do |item|
      instance = {}
      context.type.attributes.each do |k, v|
        if k == :ensure 
          instance[k] = 'present'
        else
          instance[k] = item[v[:field_name]]
        end
      end
      instances << instance
    end

    instances
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
    type = context.type.definition[:unity_resource_type_cud] || context.type.definition[:unity_resource_type]
    endpoint = context.type.definition[:create_endpoint] || "types/#{type}/instances"
    endpoint = endpoint.% type: type, name: name
    context.transport.unity_post(endpoint, body_from_should(context, should))
  end

  def update(context, name, should)
    # require 'pry';binding.pry
    context.notice("Updating '#{name}' with #{should.inspect}")
    type = context.type.definition[:unity_resource_type_cud] || context.type.definition[:unity_resource_type]
    endpoint = context.type.definition[:update_endpoint] || "instances/#{type}/name:#{name}/action/modify"
    endpoint = endpoint.% type: type, name: name
    context.transport.unity_post(endpoint, body_from_should(context, should, true))
  end

  def delete(context, name)
    # require 'pry';binding.pry
    context.notice("Deleting '#{name}'")
    type = context.type.definition[:unity_resource_type_cud] || context.type.definition[:unity_resource_type]
    endpoint = context.type.definition[:delete_endpoint] || "instances/#{type}/name:#{name}"
    endpoint = endpoint.% type: type, name: name
    context.transport.unity_post(endpoint, name)
  end

  def body_from_should(context, should, prune_init_only=false) 
    body = {}
    attrs = context.type.attributes
    should.each do |k,v|
      next if k == :ensure
      next if prune_init_only && attrs[k][:behaviour] == :init_only
      body[attrs[k][:field_name]] = v 
    end
    body
  end

end