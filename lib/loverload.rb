require "loverload/version"
require "loverload/block"
require "loverload/method"

module Loverload
  NULL = Object.new

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def def_overload(method_name_or_class, method_name = NULL, &with_params_block)
      if method_name_or_class.is_a?(Class) && method_name != NULL
        method = Method.new(method_name_or_class, method_name, &with_params_block)

        define_singleton_method method_name do |*args, &block|
          method.overload(method_name_or_class, *args, &block)
        end
      else
        method = Method.new(self, method_name_or_class, &with_params_block)

        define_method method_name_or_class do |*args, &block|
          method.overload(self, *args, &block)
        end
      end
    end
  end
end
