defmodule Servy.Plugins do
  require Logger
  alias Servy.Conv

  def prettify_path(%Conv{path: "/bears?id=" <> id} = conv) do
    %{conv | path: "/bears/" <> id}
  end

  def prettify_path(%Conv{} = conv), do: conv

  def track(%Conv{status: 404, path: path} = conv) do
    if Mix.env() != :test do
      IO.puts("Warning: #{path} is on the loose! \n")
    end

    conv
  end

  def track(%Conv{} = conv), do: conv

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  # Default clause
  def rewrite_path(%Conv{} = conv), do: conv

  def log(%Conv{} = conv) do
    if Mix.env() == :dev do
      IO.inspect(conv)
      Logger.info(conv.resp_body)
    end

    conv
  end

  def emojify(%Conv{status: 200} = conv) do
    %{conv | resp_body: ":) #{conv.resp_body} (:"}
  end

  def emojify(%Conv{} = conv), do: conv
end
