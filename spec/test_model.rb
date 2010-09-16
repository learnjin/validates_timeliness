module TestModel
  extend  ActiveSupport::Concern

  included do
    extend  ActiveModel::Translation
    include ActiveModel::Validations
    include ActiveModel::AttributeMethods
    include DynamicMethods

    attribute_method_suffix ""
    attribute_method_suffix "="
    cattr_accessor :model_attributes
  end

  module ClassMethods
    def define_method_attribute=(attr_name)
      generated_attribute_methods.module_eval("def #{attr_name}=(new_value); @attributes['#{attr_name}']=new_value ; end", __FILE__, __LINE__)
    end

    def define_method_attribute(attr_name)
      generated_attribute_methods.module_eval("def #{attr_name}; @attributes['#{attr_name}']; end", __FILE__, __LINE__)
    end
  end

  module DynamicMethods
    def method_missing(method_id, *args, &block)
      if !self.class.attribute_methods_generated?
        self.class.define_attribute_methods self.class.model_attributes.map(&:to_s)
        method_name = method_id.to_s
        send(method_id, *args, &block)
      else
        super
      end
    end
  end

  def initialize(attributes = nil)
    @attributes = self.class.model_attributes.inject({}) do |hash, column|
      hash[column.to_s] = nil
      hash
    end
    self.attributes = attributes unless attributes.nil?
  end

  def attributes
    @attributes.keys
  end

  def attributes=(new_attributes={})
    new_attributes.each do |key, value|
      send "#{key}=", value
    end
  end

end
