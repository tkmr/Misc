require 'god_growl.rb'

God.contact(:god_growl) do |c|
  c.name = 'growl'
end

God.watch do |w|
  w.name = 'test'
  w.interval = 3.seconds
  w.start = "ruby #{File.join(File.dirname(__FILE__), 'test.rb')}"
  w.log = "/tmp/hoge.txt"

  w.start_if do |s|
    s.condition(:process_running) do |c|
      c.running = false
      c.notify = 'growl'
    end
  end

  w.restart_if do |r|
    r.condition(:memory_usage) do |c|
      c.above = 2.megabytes
    end
  end
end
