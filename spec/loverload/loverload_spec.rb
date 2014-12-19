require 'loverload'

describe Loverload do
  after { Dummy.send :remove_instance_variable, :@__dictionary__ }

  it "makes your code more magical" do
    class Dummy
      include Loverload

      def_overload :hello do
        with_params do
          "Hello Nobody"
        end

        with_params do |name|
          "Hello #{ name }"
        end

        with_params do |name, age|
          "Hello #{ name } Age #{ age }"
        end
      end
    end

    dummy = Dummy.new
    dummy.hello.should eql 'Hello Nobody'
    dummy.hello('Teja').should eql 'Hello Teja'
    dummy.hello('Teja', 21).should eql 'Hello Teja Age 21'
  end

  it "raise no method error" do
    class Dummy
      include Loverload

      def_overload :hello do
        with_params Fixnum do |n|
          "Hello"
        end
      end
    end

    dummy = Dummy.new
    dummy.hello(1).should eql 'Hello'
    expect{ dummy.hello('Teja') }.to raise_error
  end

  it "makes your code even more magical" do
    class Dummy
      include Loverload

      def_overload :hello do
        with_params String do |name|
          "Hello Name: #{ name }"
        end

        with_params Fixnum do |age|
          "Hello Age: #{ age }"
        end

        with_params String, Fixnum do |name, age|
          "Hello Name: #{ name } Age: #{ age }"
        end

        with_params Fixnum, String do |age, name|
          "Hello Age: #{ age } Name: #{ name }"
        end
      end
    end

    dummy = Dummy.new
    dummy.hello('Teja').should     eql 'Hello Name: Teja'
    dummy.hello(21).should         eql 'Hello Age: 21'
    dummy.hello('Teja', 21).should eql 'Hello Name: Teja Age: 21'
    dummy.hello(21, 'Teja').should eql 'Hello Age: 21 Name: Teja'
  end

  it "makes you puke rainbow" do
    class Dummy
      include Loverload

      def_overload :before_save do
        with_params Dummy do |dummy|
          "Puke rainbow"
        end

        with_params Symbol do |symbol|
          "Puke more rainbow"
        end

        with_params Proc do |proc|
          "Puke rainbow and leprechaun"
        end

        with_params String do |string|
          "Puke rainbow, leprechaun, and gold"
        end
      end
    end

    dummy = Dummy.new
    dummy.before_save(Dummy.new).should            eql "Puke rainbow"
    dummy.before_save(:symbol).should              eql "Puke more rainbow"
    dummy.before_save(proc{|this| is proc}).should eql "Puke rainbow and leprechaun"
    dummy.before_save('string').should             eql "Puke rainbow, leprechaun, and gold"
  end

  it "can call another method" do
    class Dummy
      include Loverload

      def another_method
        'Hello from another method'
      end

      def_overload :call_another_method do
        with_params do
          another_method
        end
      end
    end

    dummy = Dummy.new

    dummy.call_another_method.should eql 'Hello from another method'
  end

  it "shared state" do
    class Dummy
      include Loverload

      def initialize
        @hello = 'World'
      end

      def another_method
        'Hello from another method'
      end

      def_overload :call_another_method do
        with_params do
          "#@hello, #{ another_method }"
        end
      end
    end

    dummy = Dummy.new

    dummy.call_another_method.should eql 'World, Hello from another method'
  end

  it "can have two overload methods" do
    class Dummy
      include Loverload

      def another_method
        'Hello from another method'
      end

      def_overload :method_1 do
        with_params do
          'method_1'
        end

        with_params do |arg|
          "method_1 with arg"
        end
      end

      def_overload :method_2 do
        with_params do
          'method_2'
        end

        with_params do |arg|
          "method_2 with arg"
        end
      end
    end

    dummy = Dummy.new
    dummy.method_1.should eql 'method_1'
    dummy.method_1(1).should eql 'method_1 with arg'
    dummy.method_2.should eql 'method_2'
    dummy.method_2(1).should eql 'method_2 with arg'
  end

  it "can overload class methods" do
    class Dummy
      include Loverload

      def_overload self, :hello do
        with_params do
          "Hello Nobody"
        end

        with_params do |name|
          "Hello #{ name }"
        end

        with_params do |name, age|
          "Hello #{ name } Age #{ age }"
        end
      end
    end

    Dummy.hello.should eql 'Hello Nobody'
    Dummy.hello('Teja').should eql 'Hello Teja'
    Dummy.hello('Teja', 21).should eql 'Hello Teja Age 21'
  end

  it "can call another class methods" do
    class Dummy
      include Loverload

      def self.hello_nobody
        "Hello Nobody"
      end

      def_overload self, :hello do
        with_params do
          hello_nobody
        end
      end
    end

    Dummy.hello.should eql 'Hello Nobody'
  end

  it "can use immediate value" do
    class Dummy
      include Loverload

      def_overload :hello do
        with_params 1 do |num|
          "One"
        end

        with_params 2 do |num|
          "Two"
        end
      end
    end

    dummy = Dummy.new
    dummy.hello(1).should eql 'One'
    dummy.hello(2).should eql 'Two'
  end

  it "supports blocks" do
    class Dummy
      include Loverload

      def_overload :hello do
        with_params String do |s|
          "Arg 1: #{s}. No block."
        end

        with_params String, Block do |s, &block|
          "Arg 1: #{s}. Block present; results in: #{block.yield}."
        end
      end
    end

    dummy = Dummy.new
    dummy.hello('str1').should eql 'Arg 1: str1. No block.'
    dummy.hello 'str2' do
      'str3' 
    end.should eql 'Arg 1: str2. Block present; results in: str3.'
  end

  it "works with inheritance" do
    class Dummy
      include Loverload

      def_overload :hello do
        with_params 1 do |num|
          "One"
        end

        with_params 2 do |num|
          "Two"
        end
      end
    end

    class Dummy2 < Dummy
    end

    dummy = Dummy2.new
    dummy.hello(1).should eql 'One'
    dummy.hello(2).should eql 'Two'
  end

  it "works with inheritance and overrides" do
    class Dummy
      include Loverload

      def_overload :hello do
        with_params 1 do |num|
          "One"
        end

        with_params 2 do |num|
          "Two"
        end
      end
    end

    class Dummy2 < Dummy
      def_overload :hello do
        with_params 1 do |num|
          "1"
        end

        with_params 2 do |num|
          "2"
        end
      end
    end

    dummy = Dummy2.new
    dummy.hello(1).should eql '1'
    dummy.hello(2).should eql '2'
  end

  it "has `guard` signature method like functor" do
    class Dummy
      include Loverload

      def_overload :hello do
        with_params ->(num){ num.odd? } do |num|
          "Odd"
        end

        with_params ->(num){ num.even? } do |num|
          "Even"
        end
      end
    end

    dummy = Dummy.new
    dummy.hello(1).should eql 'Odd'
    dummy.hello(2).should eql 'Even'
    dummy.hello(100).should eql 'Even'
  end

  it "can do fibonnaci like functor" do
    # f.given( Integer ) { | n | f.call( n - 1 ) + f.call( n - 2 ) }
    # f.given( 0 ) { |x| 0 }
    # f.given( 1 ) { |x| 1 }

    class Dummy
      include Loverload

      def_overload :fibonnaci do
        with_params 1 do |n|
          1
        end

        with_params 0 do |n|
          0
        end

        with_params Integer do |n|
          fibonnaci(n - 1) + fibonnaci(n - 2)
        end
      end
    end

    dummy = Dummy.new
    [*0..10].map(&dummy.method(:fibonnaci)).should eql [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55]
  end
end
