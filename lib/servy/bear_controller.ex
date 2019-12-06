defmodule Servy.BearController do
  alias Servy.Wildthings
  alias Servy.Bear
  alias Servy.View

  # defp bear_item(bear) do
  #   "<li>#{bear.name} - #{bear.type}</li>"
  # end

  def index(conv) do
    bears =
      Wildthings.list_bears()
      # |> Enum.filter(&Bear.is_grizzly/1)
      |> Enum.sort(&Bear.order_asc_by_name/2)

    # |> Enum.map(&bear_item/1)
    # |> Enum.join()

    View.render(conv, "index.eex", bears: bears)
  end

  def delete(conv, id) do
    %{conv | status: 204, resp_body: "Bear #{id} Deleted successfully"}
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    View.render(conv, "show.eex", bear: bear)
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{conv | status: 204, resp_body: "Created a #{type} bear named #{name}!"}
  end
end
