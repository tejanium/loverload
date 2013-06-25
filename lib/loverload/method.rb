module Loverload
  class Method
    def initialize klass, method_name, &with_params_block
      @klass       = klass
      @method_name = method_name
      instance_eval(&with_params_block)
    end

    def with_params *pars, &block
      default      = "__#{ @method_name }_#{ block.arity }"
      method_name  = "__name_#{ default }_#{ type_signature(pars) }"
      method_alias = "__alias_#{ default }_#{ alias_signature(pars) }"

      @klass.define_method method_name do |*args|
        instance_exec(*args, &block)
      end

      @klass.send :alias_method, method_alias, method_name
      @klass.send :alias_method, default, method_name

      [default, method_name, method_alias].each{ |m| @klass.send :private, m }
    end

    def overload instance, *args
      default      = "__#{ @method_name }_#{ args.size }"
      method_name  = "__name_#{ default }_#{ type_signature(args.map(&:class)) }"
      method_alias = "__alias_#{ default }_#{ alias_signature(args.map(&:class)) }"

      if instance.respond_to? method_name, true
        instance.send method_name, *args
      elsif instance.respond_to? method_alias, true
        instance.send method_alias, *args
      elsif instance.respond_to? default, true
        instance.send default, *args
      else
        raise NoMethodError, "Undefined method '#{ @method_name }' for #{ type_signature(args.map(&:class)) }"
      end
    end

    private
      def type_signature array_of_class
        array_of_class.to_s.gsub(/[\[\]]/, '')
      end

      def alias_signature array_of_class
        'Object' * array_of_class.size
      end
  end
end
