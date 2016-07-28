defmodule StringKeyword do
  def update(keywords, key, initial, fun)

  def update([{key, value} | keywords], key, _initial, fun) do
    [{key, fun.(value)} | delete(keywords, key)]
  end

  def update([{_, _} = e | keywords], key, initial, fun) do
    [e | update(keywords, key, initial, fun)]
  end

  def update([], key, initial, _fun) when is_binary(key) do
    [{key, initial}]
  end

  def delete(keywords, key, value) when is_list(keywords) and is_binary(key) do
    :lists.filter(fn {k, v} -> k != key or v != value end, keywords)
  end

  def delete(keywords, key) when is_list(keywords) and is_binary(key) do
    :lists.filter(fn {k, _} -> k != key end, keywords)
  end
end
