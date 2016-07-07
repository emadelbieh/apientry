defmodule Apientry.MobileDetection do
  @moduledocs """
  Checks if a User-Agent string is a mobile device.

  Based on: <https://gist.github.com/dalethedeveloper/1503252>
  """

  @expr ~r/Mobile|iP(hone|od|ad)|Android|BlackBerry|IEMobile|Kindle|NetFront|Silk-Accelerated|(hpw|web)OS|Fennec|Minimo|Opera M(obi|ini)|Blazer|Dolfin|Dolphin|Skyfire|Zune/

  def mobile?(agent) do
    Regex.run(@expr, agent) && true || false
  end
end
