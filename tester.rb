#!/usr/bin/env ruby
$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'loverload'

class Tester
  include Loverload

  def_overload :run! do

    with_params String do |s|
      sprintf "#run! was called with argument '%s' and no block.\n", s
    end

    with_params String, Block do |s, &block|
      sprintf "#run! was called with argument '%s' and a block yeilding '%s'.\n", s, block.call
    end

  end

end

t = Tester.new

result = t.run!('without block')
print result

result = t.run! 'with block' do
  'this is the block'
end
print result
