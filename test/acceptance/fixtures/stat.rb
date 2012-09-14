file "/tmp/test-file-chmod" do |f|
  f.content = "hello"
  f.mode = 0777
end

dir "/tmp/test-dir-chmod" do |f|
  f.mode = 01777
end

file "/tmp/test-file-chown" do |f|
  f.content = "hello"
  f.owner = "vagrant"
  f.group = "admin"
end

dir "/tmp/test-dir-chown" do |f|
  f.owner = "vagrant"
  f.group = "admin"
end
