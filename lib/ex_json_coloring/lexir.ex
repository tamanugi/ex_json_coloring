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

    iex>ExJsonColoring.Lexir.element "123", []
    {"", [%ExJsonColoring.Token{token: :number, value: "123"}]}

    iex>ExJsonColoring.Lexir.element ~s("test"), []
    {"", [%ExJsonColoring.Token{token: :string, value: "test"}]}

    iex>ExJsonColoring.Lexir.element ~s("123456"), []
    {"", [%ExJsonColoring.Token{token: :string, value: "123456"}]}

    iex>ExJsonColoring.Lexir.element ~s({"key": "value"}), []
    {
      "",
      [
        %ExJsonColoring.Token{token: :brace, value: "{"},
        %ExJsonColoring.Token{token: :key_string, value: "key"},
        %ExJsonColoring.Token{token: :colon, value: ":"},
        %ExJsonColoring.Token{token: :string, value: "value"},
        %ExJsonColoring.Token{token: :brace, value: "}"},
      ]
    }

  """
  def element(arg, acc) do
    skip_ws(arg)
    |> value(acc)
  end

  # object
  def value("{" <> rest, acc) do
    acc = acc ++ [%Token{token: :brace, value: "{"}]
    {rest_, str_val} = string_start(rest)
    acc = acc ++ [%Token{token: :key_string, value: str_val}]

    value(rest_, acc)
  end

  def value(":" <> rest, acc) do
    acc = acc ++ [%Token{token: :colon, value: ":"}]
    value(rest, acc)
  end

  def value("}" <> rest, acc) do
    acc = acc ++ [%Token{token: :brace, value: "}"}]
    value(rest, acc)
  end

  # string
  def value("", acc), do: {"", acc}
  def value(ws, acc) when ws in '\s\n\t\r', do: {"", acc}

  def value("\"" <> _ = string, acc) do
    {rest, str_val} = string_start(string)
    acc = acc ++ [%Token{token: :string, value: str_val}]
    value(rest, acc)
  end

  def string_start("\"" <> rest) do
    string(rest, "")
  end

  def string("\"" <> rest, acc), do: {rest, acc}
  def string(<<char>> <> rest, acc) do
    string(rest, acc <> <<char>>)
  end

  # number
  def value(<<char>> <> rest, acc) when char in '123456789'  do
    {rest_, number_val} = number(rest, [char])
    acc = acc ++ [%Token{token: :number, value: number_val |> List.to_string}]
    value(rest_, acc)
  end

  def number(<<char>> <> rest, acc) when char in '0123456789' do
    number(rest, acc ++ [char])
  end
  def number(rest, acc), do: {rest, acc}

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

  # ws

  def value(<<char>> <> rest, acc) when char in '\s\n\t\r' do
    value(rest, acc)
  end

  def skip_ws(<<char>> <> rest) when char in  '\s\n\t\r' do
    skip_ws(rest)
  end

  def skip_ws(string) do
    string
  end
end