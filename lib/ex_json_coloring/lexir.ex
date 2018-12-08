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

    iex>ExJsonColoring.Lexir.element ~s({"key": "value", "key2": "value2"}), []
    {
      "",
      [
        %ExJsonColoring.Token{token: :brace, value: "{"},
        %ExJsonColoring.Token{token: :key_string, value: "key"},
        %ExJsonColoring.Token{token: :colon, value: ":"},
        %ExJsonColoring.Token{token: :string, value: "value"},
        %ExJsonColoring.Token{token: :comma, value: ","},
        %ExJsonColoring.Token{token: :key_string, value: "key2"},
        %ExJsonColoring.Token{token: :colon, value: ":"},
        %ExJsonColoring.Token{token: :string, value: "value2"},
        %ExJsonColoring.Token{token: :brace, value: "}"},
      ]
    }

    iex>ExJsonColoring.Lexir.element ~s({"key": "value", "key2": {"nestk1": "nestv1"}}), []
    {
      "",
      [
        %ExJsonColoring.Token{token: :brace, value: "{"},
        %ExJsonColoring.Token{token: :key_string, value: "key"},
        %ExJsonColoring.Token{token: :colon, value: ":"},
        %ExJsonColoring.Token{token: :string, value: "value"},
        %ExJsonColoring.Token{token: :comma, value: ","},
        %ExJsonColoring.Token{token: :key_string, value: "key2"},
        %ExJsonColoring.Token{token: :colon, value: ":"},
        %ExJsonColoring.Token{token: :brace, value: "{"},
        %ExJsonColoring.Token{token: :key_string, value: "nestk1"},
        %ExJsonColoring.Token{token: :colon, value: ":"},
        %ExJsonColoring.Token{token: :string, value: "nestv1"},
        %ExJsonColoring.Token{token: :brace, value: "}"},
        %ExJsonColoring.Token{token: :brace, value: "}"},
      ]
    }

    iex>ExJsonColoring.Lexir.element ~s([1,2,3]), []
    {
      "",
      [
        %ExJsonColoring.Token{token: :square_bracket, value: "["},
        %ExJsonColoring.Token{token: :number, value: "1"},
        %ExJsonColoring.Token{token: :comma, value: ","},
        %ExJsonColoring.Token{token: :number, value: "2"},
        %ExJsonColoring.Token{token: :comma, value: ","},
        %ExJsonColoring.Token{token: :number, value: "3"},
        %ExJsonColoring.Token{token: :square_bracket, value: "]"},
      ]
    }

    iex>ExJsonColoring.Lexir.element ~s([1, {"key": "value"} , false]), []
    {
      "",
      [
        %ExJsonColoring.Token{token: :square_bracket, value: "["},
        %ExJsonColoring.Token{token: :number, value: "1"},
        %ExJsonColoring.Token{token: :comma, value: ","},
        %ExJsonColoring.Token{token: :brace, value: "{"},
        %ExJsonColoring.Token{token: :key_string, value: "key"},
        %ExJsonColoring.Token{token: :colon, value: ":"},
        %ExJsonColoring.Token{token: :string, value: "value"},
        %ExJsonColoring.Token{token: :brace, value: "}"},
        %ExJsonColoring.Token{token: :comma, value: ","},
        %ExJsonColoring.Token{token: :boolean, value: "false"},
        %ExJsonColoring.Token{token: :square_bracket, value: "]"},
      ]
    }
  """
  def element(arg, acc) do
    skip_ws(arg)
    |> value(acc, [])
  end

  def value(rest, acc), do: value(rest, acc, [])

  # en
  def value("", acc, state_stack), do: {"", acc}

  # array 
  def value("[" <> rest, acc, state_stack) do
    acc = acc ++ [%Token{token: :square_bracket, value: "["}]
    value(rest, acc, [:array | state_stack])
  end

  def value("]" <> rest, acc, [:array | tail ] = state_stack) do
    acc = acc ++ [%Token{token: :square_bracket, value: "]"}]
    value(rest, acc, tail)
  end

  # object
  def value("{" <> rest, acc, state_stack) do
    acc = acc ++ [%Token{token: :brace, value: "{"}]
    {rest_, str_val} = string_start(rest)
    acc = acc ++ [%Token{token: :key_string, value: str_val}]

    value(rest_, acc, [:object | state_stack])
  end

  def value(":" <> rest, acc, state_stack) do
    acc = acc ++ [%Token{token: :colon, value: ":"}]
    value(rest, acc, state_stack)
  end

  def value("}" <> rest, acc, [:object | tail] = state_stack) do
    acc = acc ++ [%Token{token: :brace, value: "}"}]
    value(rest, acc, tail)
  end

  def value("," <> rest, acc, [cur | _] = state_stack) do
    acc = acc ++ [%Token{token: :comma, value: ","}]

    {rest, acc} = case cur do
      :object ->
        {rest_, str_val} = string_start(rest |> skip_ws)
        {rest_, acc ++ [%Token{token: :key_string, value: str_val}]}
      _ -> 
        {rest, acc}
    end

    value(rest, acc, state_stack)
  end

  # string
  def value(ws, acc, state_stack) when ws in '\s\n\t\r', do: {"", acc}

  def value("\"" <> _ = string, acc, state_stack) do
    {rest, str_val} = string_start(string)
    acc = acc ++ [%Token{token: :string, value: str_val}]
    value(rest, acc, state_stack)
  end

  def string_start("\"" <> rest) do
    string(rest, "")
  end

  def string("\"" <> rest, acc), do: {rest, acc}
  def string(<<char>> <> rest, acc) do
    string(rest, acc <> <<char>>)
  end

  # number
  def value(<<char>> <> rest, acc, state_stack) when char in '123456789'  do
    {rest_, number_val} = number(rest, [char])
    acc = acc ++ [%Token{token: :number, value: number_val |> List.to_string}]
    value(rest_, acc, state_stack)
  end

  def number(<<char>> <> rest, acc) when char in '0123456789' do
    number(rest, acc ++ [char])
  end
  def number(rest, acc), do: {rest, acc}

  # boolean

  def value("true" <> rest, acc, state_stack) do
    acc = acc ++ [%Token{token: :boolean, value: "true"}]
    value(rest, acc, state_stack)
  end

  def value("false" <> rest, acc, state_stack) do
    acc = acc ++ [%Token{token: :boolean, value: "false"}]
    value(rest, acc, state_stack)
  end

  # null

  def value("null" <> rest, acc, state_stack) do
    acc = acc ++ [%Token{token: :null, value: "null"}]
    value(rest, acc, state_stack)
  end

  # ws

  def value(<<char>> <> rest, acc, state_stack) when char in '\s\n\t\r' do
    value(rest, acc, state_stack)
  end

  def skip_ws(<<char>> <> rest) when char in  '\s\n\t\r' do
    skip_ws(rest)
  end

  def skip_ws(string) do
    string
  end
end