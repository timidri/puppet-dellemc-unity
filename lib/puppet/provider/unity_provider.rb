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
    type = context.type.definition[:unity_resource_type]
    context.transport.unity_create_instance(type, body_from_should(should, context))
  end

  def update(context, name, should)
    # require 'pry';binding.pry
    context.notice("Updating '#{name}' with #{should.inspect}")
    type = context.type.definition[:unity_resource_type]
    context.transport.unity_update_instance(type, name, 
      body_from_should(should, context, :updating))
  end

  def delete(context, name)
    # require 'pry';binding.pry
    context.notice("Deleting '#{name}'")
    type = context.type.definition[:unity_resource_type]
    context.transport.unity_delete_instance(type, name)
  end

  def body_from_should(should, context, operation) 
    body = {}
    attrs = context.type.attributes
    should.each do |k,v|
      body[attrs[k][:field_name]] = v unless 
          # require 'pry';binding.pry
          k == :ensure || 
          (operation == :updating && attrs[k][:behaviour] == :init_only)
    end
    body
  end

end