# ActiveRecord Facade utility
#
# (C) 2008 Marcello Barnaba / Adelao S.r.L - http://www.adelaogroup.com
#  marcello.barnaba@adelao.it - http://linkedin.com/in/marcellobarnaba
#
# Released under the terms of the Ruby license.
#
# **  Usage **
# In your model: 
#  facade :attribute1, :attribute2, :with => Proc.new { |m| m.has_to_be_facaded? ? m.facaded_object : m }
# 
# Fri Jun 27 20:32:15 CEST 2008
#
module Adelao
  module Facade
    def self.enable
      ActiveRecord::Base.class_eval { extend ClassMethods }
    end

    module ClassMethods
      def facade(*attributes)
        raise ArgumentError, "missing options" unless attributes.last.is_a? Hash
        options = attributes.pop

        raise ArgumentError, "missing :with option" unless options.has_key? :with
        facade_proc = options[:with]

        attributes.each do |attribute|
          # If this method is already defined, it means it's an association.
          # Save it for later use...
          original_method = "#{attribute}_without_facade" 
          alias_method original_method, attribute if method_defined? attribute

          define_method(attribute) do
            object = facade_proc.call(self)

            # If this is the original object and we requested a a bare attribute,
            # so we can use use read_attribute to read it..
            if object.attributes.include? attribute.to_s
              object.read_attribute attribute

              # else if this is the original object but the attribute requested is
              # something like an association, call the aliased method..
            elsif object.class.method_defined? original_method
              object.__send__ original_method

              # else this is a facaded object, so feel free to call the original
              # method, it won't smash the stack :-)
            else
              object.__send__ attribute
            end
          end
        end
      end
    end
  end
end
