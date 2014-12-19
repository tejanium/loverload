module Loverload
  class Method
    def initialize klass, method_name, &with_params_block
      @klass, @method_name = klass, method_name

      dictionary || @klass.instance_variable_set(:@__dictionary__, {})

      instance_eval(&with_params_block)
    end

    def with_params(*pars, &block)
      dictionary[method_signature(block.arity, *pars)] = block
    end

    def overload(instance, *args)
      instance.instance_exec *args, &find(*args)
    end

    private
      def find(*args)
        dictionary.find do |signature, _|
          match? signature, method_signature(args.size, *args)
        end.tap{ |arr| raise NoMethodError unless arr }.last
      end

      def match?(signature, args)
        signature.zip(args).all? do |type, arg|
          type === arg
        end
      end

      def dictionary
        @klass.instance_variable_get(:@__dictionary__)
      end

      def method_signature(size, *meta)
        [*@method_name, size, *meta]
      end
  end
end
