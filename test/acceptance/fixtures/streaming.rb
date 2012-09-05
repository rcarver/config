bash "streaming output" do |s|
  s.code = <<-STR.dent
    echo -ne '#     25%\r'
    sleep 1
    echo -ne '##    50%\r'
    sleep 1
    echo -ne '###   75%\r'
    sleep 1
    echo -ne '#### 100%\r'
    sleep 1
    echo done
    sleep 1
  STR
end

bash "streaming curl status" do |s|
  s.code = "curl http://nytimes.com/ > /dev/null"
end

