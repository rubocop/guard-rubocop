# coding: utf-8

module CaptureHelper
  # rubocop:disable Eval
  def capture(stream_name)
    stream_name = stream_name.to_s.downcase
    original_stream = eval("$#{stream_name}")
    eval("$#{stream_name} = StringIO.new")

    begin
      yield
      result = eval("$#{stream_name}").string
    ensure
      eval("$#{stream_name} = original_stream")
    end

    result
  end
  # rubocop:enable Eval
end
