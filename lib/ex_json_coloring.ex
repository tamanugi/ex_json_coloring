defmodule ExJsonColoring do
  @moduledoc """
  Documentation for ExJsonColoring.
  """

  alias ExJsonColoring.Token

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

    iex>ExJsonColoring.coloring  "test"
    "hogehoge"

  """
  def coloring(str) do
    "hogehoge"
  end

  @doc """
  ## Examples

    iex>ExJsonColoring.lexir ~s({"key": "value"})
    [
      %ExJsonColoring.Token{token: :brace, value: "{"},
      %ExJsonColoring.Token{token: :key, value: "\"key\""},
      %ExJsonColoring.Token{token: :colon, value: ":"},
      %ExJsonColoring.Token{token: :string, value: "\"value\""},
      %ExJsonColoring.Token{token: :brace, value: "}"}
    ]
  """
  def lexir(json) do
    "test"
  end
end

