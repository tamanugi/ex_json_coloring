defmodule ExJsonColoring.Lexir do
  alias ExJsonColoring.Token

  def lexir(json) do
    {_, tokens} = json
    |> element([])
    tokens
  end

  @doc """
  
  ## Examples

    iex>ExJsonColoring.Lexir.element "true", []
    {"", [%ExJsonColoring.Token{type: :boolean, value: "true"}]}

    iex>ExJsonColoring.Lexir.element " false", []
    {"", [%ExJsonColoring.Token{type: :boolean, value: "false"}]}

    iex>ExJsonColoring.Lexir.element "null", []
    {"", [%ExJsonColoring.Token{type: :null, value: "null"}]}

    iex>ExJsonColoring.Lexir.element "123", []
    {"", [%ExJsonColoring.Token{type: :number, value: "123"}]}

    iex>ExJsonColoring.Lexir.element ~s("test"), []
    {"", [%ExJsonColoring.Token{type: :string, value: "test"}]}

    iex>ExJsonColoring.Lexir.element ~s("123456"), []
    {"", [%ExJsonColoring.Token{type: :string, value: "123456"}]}

    iex>ExJsonColoring.Lexir.element ~s({"key": "value"}), []
    {
      "",
      [
        %ExJsonColoring.Token{type: :brace, value: "{"},
        %ExJsonColoring.Token{type: :key_string, value: "key"},
        %ExJsonColoring.Token{type: :colon, value: ":"},
        %ExJsonColoring.Token{type: :string, value: "value"},
        %ExJsonColoring.Token{type: :brace, value: "}"},
      ]
    }

    iex>ExJsonColoring.Lexir.element ~s({"key": "value", "key2": "value2"}), []
    {
      "",
      [
        %ExJsonColoring.Token{type: :brace, value: "{"},
        %ExJsonColoring.Token{type: :key_string, value: "key"},
        %ExJsonColoring.Token{type: :colon, value: ":"},
        %ExJsonColoring.Token{type: :string, value: "value"},
        %ExJsonColoring.Token{type: :comma, value: ","},
        %ExJsonColoring.Token{type: :key_string, value: "key2"},
        %ExJsonColoring.Token{type: :colon, value: ":"},
        %ExJsonColoring.Token{type: :string, value: "value2"},
        %ExJsonColoring.Token{type: :brace, value: "}"},
      ]
    }

    iex>ExJsonColoring.Lexir.element ~s({"key": "value", "key2": {"nestk1": "nestv1"}}), []
    {
      "",
      [
        %ExJsonColoring.Token{type: :brace, value: "{"},
        %ExJsonColoring.Token{type: :key_string, value: "key"},
        %ExJsonColoring.Token{type: :colon, value: ":"},
        %ExJsonColoring.Token{type: :string, value: "value"},
        %ExJsonColoring.Token{type: :comma, value: ","},
        %ExJsonColoring.Token{type: :key_string, value: "key2"},
        %ExJsonColoring.Token{type: :colon, value: ":"},
        %ExJsonColoring.Token{type: :brace, value: "{"},
        %ExJsonColoring.Token{type: :key_string, value: "nestk1"},
        %ExJsonColoring.Token{type: :colon, value: ":"},
        %ExJsonColoring.Token{type: :string, value: "nestv1"},
        %ExJsonColoring.Token{type: :brace, value: "}"},
        %ExJsonColoring.Token{type: :brace, value: "}"},
      ]
    }

    iex>ExJsonColoring.Lexir.element ~s([1,2,3]), []
    {
      "",
      [
        %ExJsonColoring.Token{type: :square_bracket, value: "["},
        %ExJsonColoring.Token{type: :number, value: "1"},
        %ExJsonColoring.Token{type: :comma, value: ","},
        %ExJsonColoring.Token{type: :number, value: "2"},
        %ExJsonColoring.Token{type: :comma, value: ","},
        %ExJsonColoring.Token{type: :number, value: "3"},
        %ExJsonColoring.Token{type: :square_bracket, value: "]"},
      ]
    }

    iex>ExJsonColoring.Lexir.element ~s([1, {"key": "value"} , false]), []
    {
      "",
      [
        %ExJsonColoring.Token{type: :square_bracket, value: "["},
        %ExJsonColoring.Token{type: :number, value: "1"},
        %ExJsonColoring.Token{type: :comma, value: ","},
        %ExJsonColoring.Token{type: :brace, value: "{"},
        %ExJsonColoring.Token{type: :key_string, value: "key"},
        %ExJsonColoring.Token{type: :colon, value: ":"},
        %ExJsonColoring.Token{type: :string, value: "value"},
        %ExJsonColoring.Token{type: :brace, value: "}"},
        %ExJsonColoring.Token{type: :comma, value: ","},
        %ExJsonColoring.Token{type: :boolean, value: "false"},
        %ExJsonColoring.Token{type: :square_bracket, value: "]"},
      ]
    }
  """
  defp element(arg, acc) do
    skip_ws(arg)
    |> value(acc, [])
  end

  defp value(rest, acc), do: value(rest, acc, [])

  # end
  defp value("", acc, _), do: {"", acc |> Enum.reverse}

  # array
  defp value("[" <> rest, acc, state_stack) do
    token = %Token{type: :square_bracket, value: "["}
    value(rest, [token | acc], [:array | state_stack])
  end

  defp value("]" <> rest, acc, [:array | tail ]) do
    token = %Token{type: :square_bracket, value: "]"}
    value(rest, [token | acc], tail)
  end

  defp value("," <> rest, acc, [:array | _] = state_stack) do
    token = %Token{type: :comma, value: ","}
    value(rest, [token | acc], state_stack)
  end

  # object
  defp value("{" <> rest, acc, state_stack) do
    token = %Token{type: :brace, value: "{"}
    key_string(rest, [token | acc], [:object | state_stack])
  end

  defp value(":" <> rest, acc, state_stack) do
    token = %Token{type: :colon, value: ":"}
    value(rest, [token | acc], state_stack)
  end

  defp value("}" <> rest, acc, [:object | tail]) do
    token = %Token{type: :brace, value: "}"}
    value(rest, [token | acc], tail)
  end

  defp value("," <> rest, acc, [:object | _] = state_stack) do
    token = %Token{type: :comma, value: ","}
    key_string(rest, [token | acc], state_stack)
  end
  
  defp key_string(rest, acc, state_stack) do
    {rest, str_val} = string_start(rest |> skip_ws)
    token = %Token{type: :key_string, value: str_val}

    value(rest, [token | acc], state_stack)
  end

  # string
  defp value(ws, acc, _) when ws in '\s\n\t\r', do: {"", acc}

  defp value("\"" <> _ = string, acc, state_stack) do
    {rest, str_val} = string_start(string)
    token = %Token{type: :string, value: str_val}
    value(rest, [token | acc], state_stack)
  end

  defp string_start("\"" <> rest) do
    string(rest, "")
  end

  defp string("\"" <> rest, acc), do: {rest, acc}
  defp string(<<char>> <> rest, acc) do
    string(rest, acc <> <<char>>)
  end

  # number
  defp value(<<char>> <> rest, acc, state_stack) when char in '-0123456789'  do
    {rest_, number_val} = number(rest, [char])
    token = %Token{type: :number, value: number_val |> List.to_string}
    value(rest_, [token | acc], state_stack)
  end

  defp number(<<char>> <> rest, acc) when char in '0123456789.' do
    number(rest, acc ++ [char])
  end
  defp number(rest, acc), do: {rest, acc}

  # boolean

  defp value("true" <> rest, acc, state_stack) do
    token = %Token{type: :boolean, value: "true"}
    value(rest, [token | acc], state_stack)
  end

  defp value("false" <> rest, acc, state_stack) do
    token = %Token{type: :boolean, value: "false"}
    value(rest, [token | acc], state_stack)
  end

  # null

  defp value("null" <> rest, acc, state_stack) do
    token = %Token{type: :null, value: "null"}
    value(rest, [token | acc], state_stack)
  end

  # ws

  defp value(<<char>> <> rest, acc, state_stack) when char in '\s\n\t\r' do
    value(rest, acc, state_stack)
  end

  defp skip_ws(<<char>> <> rest) when char in  '\s\n\t\r' do
    skip_ws(rest)
  end

  defp skip_ws(string) do
    string
  end

end