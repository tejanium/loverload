module Loverload
  class Method
    def initialize klass, method_name, &with_params_block
      @klass, @method_name = klass, method_name
      @klass.instance_variable_set :@__dictionary__, {} unless
        @klass.instance_variable_defined? :@__dictionary__

      instance_eval(&with_params_block)
    end

    def with_params *pars, &block
      arg_count = block.arity
      arg_count += 1 if pars.last == ::Loverload::Block
      dictionary[method_signature(arg_count, *pars)] = block
    end

    def overload instance, *args, &block
      if block_given?
        args << Block.new(&block) 
        found = find(*args)
        instance.instance_exec *args do |*args|
          found.call(*args, &(args.pop.block))
        end
      else
        instance.instance_exec *args, &find(*args)
      end
    end

    private
      def find *args
        dictionary.find do |signature, _|
          match? signature, method_signature(args.size, *args)
        end.tap{ |arr| raise NoMethodError unless arr }.last
      end

      def match? signature, args
        signature.zip(args).all? do |type, arg|
          type === arg
        end
      end

      def dictionary
        @klass.instance_variable_get(:@__dictionary__)
      end

      def method_signature size, *meta
        [*@method_name, size, *meta]
      end
  end
end
