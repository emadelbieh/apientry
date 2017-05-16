defmodule Apientry.ExtensionServices do
  def extract_subid_data(string_keyword, conn) do
    subid = string_keyword
            |> StringKeyword.get("subid")

    api_key = string_keyword
              |> StringKeyword.get("apiKey")

    if subid && !api_key do
      publisher_sub_id = Repo.get_by(Apientry.PublisherSubId, sub_id: conn.params["subid"])
      geo = StringKeyword.get(string_keyword, "_country")

      [^geo, publisher_api_key, tracking_id] =
          get_api_key_and_tracking_id_from_ref_data(publisher_sub_id, geo)

      string_keyword
      |> StringKeyword.put("apiKey", publisher_api_key)
      |> StringKeyword.put("trackingId", tracking_id)
    else
      string_keyword
    end
  end

  defp get_api_key_and_tracking_id_from_ref_data(publisher_sub_id, geo) do
    publisher_sub_id.reference_data
    |> String.split(";")
    |> Enum.filter(fn ref -> ref =~ geo end)
    |> hd
    |> String.split(",")
  end
end
