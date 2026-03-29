defmodule Niceties.Notes do
  @moduledoc """
  The Notes context.
  """

  import Ecto.Query, warn: false
  alias Niceties.Accounts.Scope
  alias Niceties.Notes.Nicety
  alias Niceties.Repo

  def get_received(%Scope{} = scope, group_id) do
    Ecto.assoc(scope.user, :niceties_to)
    |> where([nicety], nicety.group_id == ^group_id)
    |> Repo.all()
    |> Repo.preload(:user_from)
    |> Enum.map(fn nicety ->
      if nicety.anonymous do
        # Remove the provider of the nicety for anonymity
        %{nicety | user_from: nil}
      else
        nicety
      end
    end)
  end

  def get_given(%Scope{} = scope, group_id) do
    Ecto.assoc(scope.user, :niceties_from)
    |> where([nicety], nicety.group_id == ^group_id)
    |> Repo.all()
  end

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

  def upsert_nicety(attrs) do
    %Nicety{}
    |> Nicety.changeset(attrs)
    |> Repo.insert(
      on_conflict: {:replace, [:body, :anonymous, :updated_at]},
      conflict_target: [:user_from_id, :user_to_id, :group_id]
    )
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
