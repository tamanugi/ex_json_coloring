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
      %ExJsonColoring.Token{token: :key, value: "\\"key\\""},
      %ExJsonColoring.Token{token: :colon, value: ":"},
      %ExJsonColoring.Token{token: :string, value: "\\"value\\""},
      %ExJsonColoring.Token{token: :brace, value: "}"}
    ]
  """
  def lexir(json) do
    json
    |> parse(nil, [])
  end

  def parse("{" <> rest, state, tokens) do
    token = %Token{token: :brace, value: "{"}
    parse(rest, :find_key, [token] ++ tokens)
  end

  def parse("\"" <> rest, state, tokens) do
    {string, rest} = string_continue(rest)

    token_type = case state do
      :find_key -> :key
      _ -> :string
    end

    token = %Token{token: token_type, value: "\"#{string}\""}
    parse(rest, :string, [token] ++ tokens)
  end

  def parse(":" <> rest, state, tokens) do
    token = %Token{token: :colon, value: ":"}
    parse(rest, state, [token] ++ tokens)
  end

  def parse("}" <> _, _, tokens) do
    token = %Token{token: :brace, value: "}"}
    [token] ++ tokens
    |> Enum.reverse
  end

  def parse(" " <> rest, state, tokens) do
    parse(rest, state, tokens)
  end

  defp string_continue("\"" <> rest, acc) do
    # {IO.iodata_to_binary(acc), rest}
    {acc, rest}
  end

  # defp string_continue("", _), do: syntax_error(nil, pos)

  defp string_continue(string) do
    count = string_chunk_size(string, 0)
    <<chunk::binary-size(count), rest::binary>> = string
    string_continue(rest, chunk)
  end

  defp string_chunk_size("\"" <> _, acc), do: acc
  defp string_chunk_size("\\" <> _, acc), do: acc

  # # Control Characters (http://seriot.ch/parsing_json.php#25)
  # defp string_chunk_size(<<char>> <> _rest, _acc) when char <= 0x1F do
  #   syntax_error(<<char>>)
  # end

  defp string_chunk_size(<<char>> <> rest, acc) when char < 0x80 do
    string_chunk_size(rest, acc + 1)
  end

  defp string_chunk_size(<<codepoint::utf8>> <> rest, acc) do
    string_chunk_size(rest, acc + string_codepoint_size(codepoint))
  end

  defp string_codepoint_size(codepoint) when codepoint < 0x800, do: 2
  defp string_codepoint_size(codepoint) when codepoint < 0x10000, do: 3
  defp string_codepoint_size(_), do: 4

  # defp string_chunk_size(other, _acc), do: syntax_error(other, pos)

end

