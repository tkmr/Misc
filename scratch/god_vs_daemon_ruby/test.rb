p 'start test.rb'

i = []
while true
  p "...#{ (i << i.size) } (test.rb)"
  open('/tmp/log', 'a') {|file| file << i.join(' ') + "\n" }

  sleep 0.1
end
