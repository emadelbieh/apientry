defmodule CsvCacheSupervisor do
  use Supervisor

  @name CsvCacheSupervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_cache do
    Supervisor.start_child(@name, [])
  end

  def init(:ok) do
    children = [
      worker(CsvCache, [], restart: :temporary)
    ]

    #geo = "us"

    #CsvCacheRegistry.create(CsvCacheRegistry, geo)
    #{:ok, cache} = CsvCacheRegistry.lookup(CsvCacheRegistry, geo)

    #Path.expand(".")
    #|> Path.join("/web/services/#{geo}_cat_id_attr_regex.csv")
    #|> File.stream!()
    #|> CSV.decode()
    #|> Enum.each(fn [cat_id, regex] ->
    #  CsvCache.put(cache, cat_id, regex)
    #end)

    #|> Enum.reduce(%{}, fn [cat_id, regex], acc ->
    #  CsvCache.put(cache, "test", ~r/test/)
    #  Map.put(acc, cat_id, regex)
    #end)


    #CsvCache.get(cache, "test")

    supervise(children, strategy: :simple_one_for_one)
  end
end
