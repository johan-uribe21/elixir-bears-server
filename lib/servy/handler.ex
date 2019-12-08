defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP Request
  """
  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.VideoCam
  alias Servy.Fetcher
  @pages_path Path.expand("../../pages", __DIR__)

  @doc """
  Transforms the request into a response.
  """
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    # |> prettify_path
    |> log
    |> route
    |> track
    |> put_content_length
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/sensors"} = conv) do
    pid1 = Fetcher.async(fn -> VideoCam.get_snapshot("cam-1") end)
    pid2 = Fetcher.async(fn -> VideoCam.get_snapshot("cam-2") end)
    pid3 = Fetcher.async(fn -> VideoCam.get_snapshot("cam-3") end)
    pid4 = Fetcher.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshot1 = Fetcher.get_result(pid1)
    snapshot2 = Fetcher.get_result(pid2)
    snapshot3 = Fetcher.get_result(pid3)
    where_is_bigfoot = Fetcher.get_result(pid4)

    snapshots = [snapshot1, snapshot2, snapshot3]

    %{conv | status: 200, resp_body: inspect({snapshots, where_is_bigfoot})}
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    BearController.delete(conv, id)
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    IO.puts("Entered the bears/new route handler")

    @pages_path
    |> Path.join("form.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv, conv.params)
  end

  def route(%{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{conv.resp_body}
    """
  end

  defp format_response_headers(conv) do
    for {key, value} <- conv.resp_headers do
      "#{key}: #{value}\r"
    end
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  defp put_content_length(conv) do
    headers = Map.put(conv.resp_headers, "Content-Length", String.length(conv.resp_body))
    %{conv | resp_headers: headers}
  end
end
