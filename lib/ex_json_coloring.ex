defmodule ExJsonColoring do
  @moduledoc """
  Documentation for ExJsonColoring.
  """

  alias ExJsonColoring.Token
  alias ExJsonColoring.Lexir

  @tokens [
    :square_bracket,
    :brace,
    :colon,
    :comma,

    :key,
    :string,
    :number,
    :boolean
  ]

  @doc """
  
  ## Examples

    iex>ExJsonColoring.coloring  ~s({"key": "value"})
    "test"

  """
  def coloring(json) do
    Lexir.lexir(json)
    |> Enum.map(fn token ->
      %Token{token: type, value: value} = token
      color = case type do
        :brace -> :color202
        :key -> :color101
        :colon -> :darkblue
        :string -> :hotpink
      end

      [color, value]
    end)
    |> List.flatten
    |> Bunt.ANSI.format
    |> IO.puts
  end
end

