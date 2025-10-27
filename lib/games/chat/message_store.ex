defmodule Games.Chat.MessageStore do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def all do
    Agent.get(__MODULE__, & &1)
  end

  def add(message, author) do
    Agent.update(__MODULE__, fn list ->
      list ++ [%{:message => message, :author => author}]
    end)
  end
end
