defmodule ExJsonColoring.Lexir do
  alias ExJsonColoring.Token

  def lexir(json) do
    json
    |> element([])
  end

  @doc """
  
  ## Examples

    iex>ExJsonColoring.Lexir.element "true", []
    {"", [%ExJsonColoring.Token{token: :boolean, value: "true"}]}

    iex>ExJsonColoring.Lexir.element " false", []
    {"", [%ExJsonColoring.Token{token: :boolean, value: "false"}]}

    iex>ExJsonColoring.Lexir.element "null", []
    {"", [%ExJsonColoring.Token{token: :null, value: "null"}]}

  """
  def element(arg, acc) do
    skip_ws(arg)
    |> value(acc)
  end

  # boolean

  def value("true" <> rest, acc) do
    {rest, acc ++ [%Token{token: :boolean, value: "true"}]}
  end

  def value("false" <> rest, acc) do
    {rest, acc ++ [%Token{token: :boolean, value: "false"}]}
  end

  # null

  def value("null" <> rest, acc) do
    {rest, acc ++ [%Token{token: :null, value: "null"}]}
  end

  def skip_ws(<<char>> <> rest) when char in  '\s\n\t\r' do
    skip_ws(rest)
  end

  def skip_ws(string) do
    string
  end
end