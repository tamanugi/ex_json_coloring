defmodule ExJsonColoring do
  @moduledoc """
  Documentation for ExJsonColoring.
  """

  alias ExJsonColoring.Token
  alias ExJsonColoring.Lexir

  def coloring(json) do
    Lexir.lexir(json)
    |> process_format(0, [])
    |> List.flatten
    |> Bunt.ANSI.format
    |> IO.puts
  end

  defp process_format([], 0, acc), do: acc
  defp process_format([%Token{type: type, value: value} | tail] , indent_lv, acc) do
    {formated, indent_lv} = format(type, value, indent_lv)
    process_format(tail, indent_lv, acc ++ [formated])
  end

  defp format(:brace, value, indent_lv) do
    case value do
      "{" ->
        {[color(:brace), "{", "\n", indent(indent_lv + 1)], indent_lv + 1}
      "}" ->
        {["\n", indent(indent_lv - 1), color(:brace), "}"], indent_lv - 1}
    end
  end

  defp format(:square_bracket, value, indent_lv) do
    case value do
      "[" ->
        {[color(:square_bracket), "[", "\n", indent(indent_lv + 1)], indent_lv + 1}
      "]" ->
        {["\n", indent(indent_lv - 1), color(:square_bracket), "]"], indent_lv - 1}
    end
  end  

  defp format(:comma, ",", indent_lv) do
    {[",", "\n", indent(indent_lv)], indent_lv}
  end

  defp format(:colon, ":", indent_lv) do
    {[":", " "], indent_lv}
  end

  defp format(type, value, indent_lv) when type in [:string, :key_string] do
    {[color(type), "\"#{value}\""], indent_lv}
  end

  defp format(type, value, indent_lv) do
    {[color(type), value], indent_lv}
  end

  defp indent(0), do: ""
  defp indent(indent_lv) do
    for _ <- 1..(indent_lv * 2), do: " "
  end

  defp color(:string), do: :green 
  defp color(:key_string), do: :fuchsia
  defp color(:boolean), do: :blue
  defp color(:number), do: :lightyellow
  defp color(:null), do: :lightgray
  defp color(_), do: Bunt.ANSI.reset
end
