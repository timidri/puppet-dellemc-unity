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
        instance[k] = item[v[:field_name]]
      end
      instances << instance
    end

    instances
  end

end