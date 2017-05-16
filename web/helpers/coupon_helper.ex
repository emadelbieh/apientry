defmodule Apientry.CouponHelper do
  def base_struct() do
    {_, {hour, minute, _}} = Timex.to_erl(Timex.now())
    if (hour in [0,6,12,18]) && (minute in 0..30) do
      %Apientry.CouponCopy{}
    else
      %Apientry.Coupon{}
    end
  end

  def base_model do
    {_, {hour, minute, _}} = Timex.to_erl(Timex.now())
    if (hour in [0,6,12,18]) && (minute in 0..30) do
      Apientry.CouponCopy
    else
      Apientry.Coupon
    end
  end
end
