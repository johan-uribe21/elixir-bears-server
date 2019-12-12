defmodule Servy.PledgeServerHandRolled do
  @name :pledge_server_hand_rolled
  alias Servy.GenericServerHandRolled
  # Client interface functions

  def start do
    GenericServerHandRolled.start(__MODULE__, [], @name)
  end

  def clear do
    GenericServerHandRolled.cast(@name, :clear)
  end

  def create_pledge(name, amount) do
    GenericServerHandRolled.call(@name, {:create_pledge, name, amount})
  end

  def recent_pledges() do
    GenericServerHandRolled.call(@name, :recent_pledges)
  end

  def total_pledged() do
    GenericServerHandRolled.call(@name, :total_pledged)
  end

  defp send_pledge_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  # Server Callbacks

  def handle_cast(:clear, _state) do
    []
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [{name, amount} | most_recent_pledges]
    {id, new_state}
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call(:total_pledged, state) do
    total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
    {total, state}
  end
end
