require "concurrent"
require "progressbar"

class Array
  def all_combinations
    length.times.flat_map { |n| combination(n).to_a }
  end
end

$pool = Concurrent::FixedThreadPool.new(1 << 6)
$stdcom = File.open("stdcom", "a")

def system!(*args)
  $pool.post do
    puts Formatter.headline(args.join(" "))
    system(*args)
    $progress.increment
  end
end

puts "Hello world"

options = [
  [["--recursive"], []],
  ["--include-build", "--include-optional",
   #"--skip-recommended"
   ].all_combinations,
#   [["--devel"], ["--HEAD"], []],
#   [["--installed"], []],
]

puts "Permuting"

all = [[]]
options.each do |possibilities|
  all = all.flat_map { |a| possibilities.map { |p| a + p } }
end

puts "All options calculated"

jobs = all.count * Formula.count

puts "Progress bar initializing (#{jobs} jobs)"

$progress = ProgressBar.create(total: jobs, output: IO.new(IO.sysopen("/dev/tty", "w"), "w"), format: " [ %w%i ] %E ")

puts "Queuing jobs"

Formula.each do |f|
  all.each { |l| system! "brew", "uses", *l, f.full_name }
end

puts "All jobs queued"

$pool.shutdown
$pool.wait_for_termination
