Dir["./spec/support/**/*.rb"].each { |f| require f }

def capture_stdout(&block)
  old_stdout = $stdout.dup
  $stdout = fake = StringIO.new
  yield
  fake.string
  ensure
    $stdout = old_stdout
end
