defmodule Apientry.UUIDGenerator do
  # keep this always in sync with Events.UUIDGenerator
  def generate(user_ip, publisher_id) do
    UUID.uuid5(:url, "#{user_ip}/#{publisher_id}")
  end
end
