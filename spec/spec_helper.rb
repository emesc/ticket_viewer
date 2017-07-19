Dir["./spec/support/**/*.rb"].each { |f| require f }

def fake_user_input(*args)
  allow(Readline).to receive(:readline).and_return(*args)
end

def capture_stdout(&block)
  old_stdout = $stdout.dup
  $stdout = fake = StringIO.new
  yield
  fake.string
  ensure
    $stdout = old_stdout
end

def silence_output
  # Store the original stderr and stdout in order to restore them later
  @original_stderr = $stderr
  @original_stdout = $stdout

  # Redirect stderr and stdout
  $stderr = File.new(File.join(File.dirname(__FILE__), 'dev', 'null.txt'), 'w+')
  $stdout = File.new(File.join(File.dirname(__FILE__), 'dev', 'null.txt'), 'w+')
end
