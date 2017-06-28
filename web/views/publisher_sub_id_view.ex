defmodule Apientry.PublisherSubIdView do
  use Apientry.Web, :view


  def render("query.json", %{subids: subids}) do
    subids = subids
    |> Enum.map(fn subid ->
      %{sub_id: subid.sub_id,
        reference_data: subid.reference_data}
    end)

    %{subids: subids}
  end
end
