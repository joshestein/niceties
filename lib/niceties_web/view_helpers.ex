defmodule NicetiesWeb.ViewHelpers do
  @doc """
  Returns up to two initials from a user's name, or "?" for nil.
  """
  def initials(nil), do: "?"

  def initials(user) do
    user.name
    |> String.split()
    |> Enum.take(2)
    |> Enum.map(&String.first/1)
    |> Enum.join()
    |> String.upcase()
  end
end
