require "loverload/version"
require "loverload/method"

module Loverload
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def def_overload method_name, &with_params_block
      method = Method.new(self, method_name, &with_params_block)

      define_method method_name do |*args|
        method.overload(self, *args)
      end
    end
  end
end
