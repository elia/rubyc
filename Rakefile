TEST_FILE = 'test/test.rb.packed.rb'

task TEST_FILE do
  sh 'ruby -Itest ./rubyc.rb test/test.rb'
end

task :test => TEST_FILE do
  sh 'ruby -s test/test.rb.packed.rb'
end

task :bench => TEST_FILE do
  require 'benchmark/ips'
  require 'benchmark/ips'

  Benchmark.ips do |x|
    # Configure the number of seconds used during
    # the warmup phase (default 2) and calculation phase (default 5)
    x.config(:time => 10, :warmup => 0)

    # Typical mode, runs the block as many times as it can
    x.report("straight") { system 'ruby -Itest -s test/test.rb    > /dev/null' }
    x.report("compiled") { system 'ruby -s test/test.rb.packed.rb > /dev/null' }
  end
end
