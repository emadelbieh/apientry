defmodule Apientry.Slack do
  @endpoint "https://hooks.slack.com/services/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"
  alias Apientry.HTTP

  def send_message(message) do
    payload = ~s({"text" : "#{message}"})
    HTTP.post @endpoint, payload
  end
end
