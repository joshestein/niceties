defmodule Niceties.Groups do
  @moduledoc """
  The Groups context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Niceties.Accounts
  alias Niceties.Accounts.Scope
  alias Niceties.Accounts.User
  alias Niceties.Groups.Group
  alias Niceties.Groups.Membership
  alias Niceties.Repo

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups do
    Repo.all(Group)
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group!(id), do: Repo.get!(Group, id)

  @doc """
  Returns all memberships of a group.
  """
  def get_all_memberships(group_or_id, confirmed_only \\ false)

  def get_all_memberships(%Group{} = group, confirmed_only) do
    query = Ecto.assoc(group, :memberships)

    query =
      if confirmed_only do
        from m in query, join: u in User, on: m.user_id == u.id, where: not is_nil(u.confirmed_at)
      else
        query
      end

    Repo.all(query) |> Repo.preload(:user)
  end

  def get_all_memberships(id, confirmed_only) do
    get_group!(id) |> get_all_memberships(confirmed_only)
  end

  def list_groups_for_user(%Scope{} = scope) do
    memberships =
      Ecto.assoc(scope.user, :memberships)
      |> Repo.all()
      |> Repo.preload(:group)

    Enum.map(memberships, fn membership -> membership.group end)
  end

  def list_admin_groups_for_user(%Scope{} = scope) do
    memberships =
      Ecto.assoc(scope.user, :memberships)
      |> where([m], m.role == "admin")
      |> Repo.all()
      |> Repo.preload(:group)

    Enum.map(memberships, fn membership -> membership.group end)
  end

  def is_admin_of_group?(user_id, group_id) do
    Repo.exists?(
      from m in Membership,
        where: m.user_id == ^user_id and m.group_id == ^group_id and m.role == "admin"
    )
  end

  def member_of_group?(user_id, group_id) do
    Repo.exists?(from m in Membership, where: m.user_id == ^user_id and m.group_id == ^group_id)
  end

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(attrs) do
    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{data: %Group{}}

  """
  def change_group(%Group{} = group, attrs \\ %{}) do
    Group.changeset(group, attrs)
  end

  @doc """
  Returns the list of memberships.

  ## Examples

      iex> list_memberships()
      [%Membership{}, ...]

  """
  def list_memberships do
    Repo.all(Membership)
  end

  @doc """
  Returns memberships for a user.
  """
  def list_memberships(%Scope{} = scope) do
    Repo.all(Ecto.assoc(scope.user, :memberships))
  end

  @doc """
  Gets a single membership.

  Raises `Ecto.NoResultsError` if the Membership does not exist.

  ## Examples

      iex> get_membership!(123)
      %Membership{}

      iex> get_membership!(456)
      ** (Ecto.NoResultsError)

  """
  def get_membership!(id), do: Repo.get!(Membership, id)

  @doc """
  Creates a membership.

  ## Examples

      iex> create_membership(%{field: value})
      {:ok, %Membership{}}

      iex> create_membership(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_membership(attrs) do
    %Membership{}
    |> Membership.changeset(attrs)
    |> Repo.insert()
  end

  def create_member(attrs) do
    Multi.new()
    |> Multi.run(:resolved_user, fn _repo, _changes ->
      case Accounts.get_user_by_email(attrs[:email]) do
        nil -> Accounts.create_user(attrs)
        user -> {:ok, user}
      end
    end)
    |> Multi.insert(:membership, fn %{resolved_user: user} ->
      Membership.changeset(%Membership{}, %{
        role: attrs[:role],
        group_id: attrs[:group_id],
        user_id: user.id
      })
    end)
    |> Repo.transact()
  end

  @doc """
  Updates a membership.

  ## Examples

      iex> update_membership(membership, %{field: new_value})
      {:ok, %Membership{}}

      iex> update_membership(membership, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_membership(%Membership{} = membership, attrs) do
    membership
    |> Membership.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a membership.

  ## Examples

      iex> delete_membership(membership)
      {:ok, %Membership{}}

      iex> delete_membership(membership)
      {:error, %Ecto.Changeset{}}

  """
  def delete_membership(%Membership{} = membership) do
    Repo.delete(membership)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking membership changes.

  ## Examples

      iex> change_membership(membership)
      %Ecto.Changeset{data: %Membership{}}

  """
  def change_membership(%Membership{} = membership, attrs \\ %{}) do
    Membership.changeset(membership, attrs)
  end
end
