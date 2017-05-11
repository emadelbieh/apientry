defmodule Apientry.Slack do
  @endpoint "https://hooks.slack.com/services/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"

  def send_message(message) do
    payload = ~s({"text" : "#{message}"})
    HTTPoison.post @endpoint, payload
  end
end
