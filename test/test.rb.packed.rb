  $rubyc_modules = Marshal.load(DATA.read)
  $rubyc_top = self

  module RUBYC
    def self.exec_ruby(code, filename = '<required>')
      top = $rubyc_top.clone
      wrapper = Module.new
      top.extend wrapper
      top.instance_eval(code)
    end
  end

  module Kernel
    alias original_require require
    def require(filename)
      return false if $LOADED_FEATURES.include? filename
      code = $rubyc_modules[filename]
      # raise LoadError, "cannot load such file -- #{filename}" if code.nil?
      return original_require(filename) if code.nil?
      RUBYC.exec_ruby(code, filename)
      $LOADED_FEATURES << filename
    end
  end

require "test/test.rb"
__END__
{	I"test/test.rb:ETI"Drequire 'file1'
require 'file2'
if false
  require 'file3'
end
; TI"
file1; TI"puts 1
; TI"
file2; TI"puts 2
; TI"
file3; TI"puts 3
; T