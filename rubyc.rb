#!/usr/bin/env ruby

def main(filename)
  code = File.read(filename)
  repo = {filename => code}
  requires = parse_requires_from(code)
  add_requires_to_repo(requires, repo)
  File.open(filename+'.packed.rb', 'w') do |file|
    file << setup_code
    file << "require #{filename.inspect}"
    file.puts
    file.puts '__END__'
    file << Marshal.dump(repo)
  end
end

def setup_code
  <<-RUBY
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
      # raise LoadError, "cannot load such file -- \#{filename}" if code.nil?
      return original_require(filename) if code.nil?
      RUBYC.exec_ruby(code, filename)
      $LOADED_FEATURES << filename
    end
  end

  RUBY
end

def add_requires_to_repo(requires, repo)
  requires.each do |required_file|
    next if repo[required_file]
    full_path = nil

    $:.find do |path|
      full_path = File.join(path, required_file + '.rb')
      File.exist? full_path
    end

    repo[required_file] = File.read(full_path)
  end
end

def parse_requires_from(code)
  code.scan(%r{\brequire *'([^']+)'}).flatten
end

main(ARGV.first)
