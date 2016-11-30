defmodule Rumbl.Permalink do
  @behaviour Ecto.Type

  def type, do: :id

  def cast(binary) when is_binary(binary) do
    case Integer.parse(binary) do
      {int, _} when int > 0 -> {:ok, int}
      _ -> :error
    end
  end

  def cast(int) when is_integer(int) do
    {:ok, int}
  end

  def cast(_) do
    :error
  end

  def dump(int) when is_integer(int) do
    {:ok, int}
  end

  def load(int) when is_integer(int) do
    {:ok, int}
  end

end
