defmodule Niceties.Notes do
  @moduledoc """
  The Notes context.
  """

  import Ecto.Query, warn: false
  alias Niceties.Repo

  alias Niceties.Notes.Nicety

  @doc """
  Returns the list of niceties.

  ## Examples

      iex> list_niceties()
      [%Nicety{}, ...]

  """
  def list_niceties do
    Repo.all(Nicety)
  end

  @doc """
  Gets a single nicety.

  Raises `Ecto.NoResultsError` if the Nicety does not exist.

  ## Examples

      iex> get_nicety!(123)
      %Nicety{}

      iex> get_nicety!(456)
      ** (Ecto.NoResultsError)

  """
  def get_nicety!(id), do: Repo.get!(Nicety, id)

  @doc """
  Creates a nicety.

  ## Examples

      iex> create_nicety(%{field: value})
      {:ok, %Nicety{}}

      iex> create_nicety(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_nicety(attrs) do
    %Nicety{}
    |> Nicety.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a nicety.

  ## Examples

      iex> update_nicety(nicety, %{field: new_value})
      {:ok, %Nicety{}}

      iex> update_nicety(nicety, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_nicety(%Nicety{} = nicety, attrs) do
    nicety
    |> Nicety.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a nicety.

  ## Examples

      iex> delete_nicety(nicety)
      {:ok, %Nicety{}}

      iex> delete_nicety(nicety)
      {:error, %Ecto.Changeset{}}

  """
  def delete_nicety(%Nicety{} = nicety) do
    Repo.delete(nicety)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking nicety changes.

  ## Examples

      iex> change_nicety(nicety)
      %Ecto.Changeset{data: %Nicety{}}

  """
  def change_nicety(%Nicety{} = nicety, attrs \\ %{}) do
    Nicety.changeset(nicety, attrs)
  end
end
