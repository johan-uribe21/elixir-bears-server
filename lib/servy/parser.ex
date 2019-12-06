defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\r\n\r\n")

    [request_line | header_lines] = String.split(top, "\r\n")

    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines)

    params = parse_params(headers["Content-Type"], params_string)

    IO.inspect(header_lines)

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  @doc """
  Parses the given param string of the form ... into a map with corresponding keys and values

  ## Examples

  """
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim() |> URI.decode_query()
  end

  def parse_params("application/json", params_string) do
    params_string |> Poison.Parser.parse!(%{})
  end

  def parse_params(_, _), do: %{}

  def parse_headers(header_lines) do
    parse_line = fn line, map ->
      [key, value] = String.split(line, ": ")
      Map.put(map, key, value)
    end

    Enum.reduce(header_lines, %{}, parse_line)

    # [key, value] = String.split(head, ": ")
    # headers = Map.put(headers, key, value)
    # parse_headers(tail, headers)
  end

  # def parse_headers([], headers), do: headers
end
