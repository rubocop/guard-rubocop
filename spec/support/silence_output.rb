# coding: utf-8

shared_context 'silence output', silence_output: true do
  before do
    null_output = double('output').as_null_object

    @original_stdout = $stdout
    @original_stderr = $stderr

    $stdout = null_output
    $stderr = null_output
  end

  after do
    $stdout = @original_stdout
    $stderr = @original_stderr
  end
end
