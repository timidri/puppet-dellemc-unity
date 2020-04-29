require 'puppet/resource_api/simple_provider'

# A base provider for all PANOS providers
class Puppet::Provider::UnityProvider < Puppet::ResourceApi::SimpleProvider

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
    unity_resource_type = context.type.definition[:unity_resource_type]
    context.transport.unity_post("types/#{unity_resource_type}/instances", body_from_should(should, context))
  end

  def update(context, name, should)
    # require 'pry';binding.pry
    context.notice("Updating '#{name}' with #{should.inspect}")
    unity_resource_type = context.type.definition[:unity_resource_type]
    context.transport.unity_post("instances/#{unity_resource_type}/name:#{name}/action/modify", 
      body_from_should(should, context))
  end

  def delete(context, name)
    # require 'pry';binding.pry
    context.notice("Deleting '#{name}'")
    unity_resource_type = context.type.definition[:unity_resource_type]
    context.transport.unity_delete("instances/#{unity_resource_type}/name:#{name}")
  end

  def body_from_should(should, context)
    # require 'pry';binding.pry
    body = {}
    should.each do |k,v|
      body[context.type.attributes[k][:field_name]] = v unless k == :ensure
    end
    body
  end

end