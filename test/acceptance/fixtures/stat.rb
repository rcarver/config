file "/tmp/file-test-chmod" do |f|
  f.content = "hello"
  f.mode = 0777
end

dir "/tmp/dir-test-chmod" do |f|
  #f.mode = 01777
end

file "/tmp/file-test-chown" do |f|
  f.content = "hello"
  f.owner = "vagrant"
  f.group = "admin"
end

dir "/tmp/dir-test-chown" do |f|
  f.owner = "vagrant"
  f.group = "admin"
end

