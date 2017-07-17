Dir["./spec/support/**/*.rb"].each { |f| require f }

def fake_user_input(*args)
  allow(Readline).to receive(:readline).and_return(*args)
end

def capture_stdout(&block)
  old_stdout = $stdout.dup
  fake = StringIO.new
  $stdout = fake
  begin
    yield
  ensure
    $stdout = old_stdout
  end
  fake.string
end
