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
      args << Block.new(&block) if block_given?
      found = find(*args)
      found_proc = Proc.new do |*args|
        if args.last.is_a?(::Loverload::Block)
          found.call *args, &(args.pop.block)
        else
          found.call *args
        end
      end
      instance.instance_exec *args, &found_proc
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
