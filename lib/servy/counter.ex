# Refactored to use the Generic Server Module

defmodule Servy.FourOhFourCounter do
  @name :four_oh_four_counter
  alias Servy.GenericServer

  # Client Interface
  def start do
    GenericServer.start(__MODULE__, %{}, @name)
    # pid = spawn(__MODULE__, :listen_loop, [%{}])
    # Process.register(pid, @name)
  end

  def bump_count(path) do
    GenericServer.call(@name, {:bump_count, path})
    # send(@name, {self(), :bump_count, path})

    # receive do
    #   {:response, count} -> count
    # end
  end

  def get_counts do
    GenericServer.call(@name, {:get_counts})
    # send(@name, {self(), :get_counts})

    # receive do
    #   {:response, counts} -> counts
    # end
  end

  def get_count(path) do
    GenericServer.call(@name, {:get_count, path})
    # send(@name, {self(), :get_count, path})

    # receive do
    #   {:response, count} -> count
    # end
  end

  # # Server - Using Generic Server module now.
  # def listen_loop(state) do
  #   receive do
  #     {sender, :bump_count, path} ->
  #       # new_state = Map.update(state, path, 1, &(&1 + 1))
  #       send(sender, {:response, :ok})
  #       listen_loop(new_state)

  #     {sender, :get_counts} ->
  #       send(sender, {:response, state})
  #       listen_loop(state)

  #     {sender, :get_count, path} ->
  #       count = Map.get(state, path, 0)
  #       send(sender, {:response, count})
  #       listen_loop(state)

  #     unexpected ->
  #       IO.puts("Unexpected message: #{inspect(unexpected)}")
  #       listen_loop(state)
  #   end
  # end

  def handle_call({:bump_count, path}, state) do
    new_state = Map.update(state, path, 1, &(&1 + 1))
    {:ok, new_state}
  end

  def handle_call({:get_counts}, state) do
    {state, state}
  end

  def handle_call({:get_count, path}, state) do
    count = Map.get(state, path, 0)
    {count, state}
  end

  def handle_cast(:reset, _state) do
    %{}
  end
end
