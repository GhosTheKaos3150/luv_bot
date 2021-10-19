defmodule BoolCast do
  def boolcast!("true"), do: true
  def boolcast!("false"), do: false
  def boolcast!(_anyelse), do: false
end
