defmodule ExJsonColoring do
  @moduledoc """
  Documentation for ExJsonColoring.
  """

  alias ExJsonColoring.Token
  alias ExJsonColoring.Lexir

  @doc """
  
  ## Examples

    iex>ExJsonColoring.coloring  ~s({"key": "value"})
    {
      "key": "value"
    }

  """
  def coloring(json) do
    Lexir.lexir(json)
    |> process_format(0, [])
    |> List.flatten
    |> Bunt.ANSI.format
    |> IO.puts
  end

  def process_format([], 0, acc), do: acc
  def process_format([%Token{token: type, value: value} | tail] , indent_lv, acc) do
    {formated, indent_lv} = format(type, value, indent_lv)
    process_format(tail, indent_lv, acc ++ [formated])
  end

  def format(:brace, value, indent_lv) do
    case value do
      "{" ->
        {[color(:brace), "{", "\n", indent(indent_lv + 1)], indent_lv + 1}
      "}" ->
        {["\n", indent(indent_lv - 1), color(:brace), "}"], indent_lv - 1}
    end
  end

  def format(:square_bracket, value, indent_lv) do
    case value do
      "[" ->
        {[color(:square_bracket), "[", "\n", indent(indent_lv + 1)], indent_lv + 1}
      "]" ->
        {["\n", indent(indent_lv - 1), color(:square_bracket), "]"], indent_lv - 1}
    end
  end  

  def format(:comma, ",", indent_lv) do
    {[",", "\n", indent(indent_lv)], indent_lv}
  end

  def format(:colon, ":", indent_lv) do
    {[":", " "], indent_lv}
  end

  def format(type, value, indent_lv) when type in [:string, :key_string] do
    {[color(type), "\"#{value}\""], indent_lv}
  end

  def format(type, value, indent_lv) do
    {[color(type), value], indent_lv}
  end

  def indent(0), do: ""
  def indent(indent_lv) do
    for _ <- 1..(indent_lv * 2), do: " "
  end

  def color(_) do
    :red
  end
end

