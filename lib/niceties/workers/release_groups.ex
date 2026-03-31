defmodule Niceties.Workers.ReleaseGroups do
  alias Niceties.Groups
  use Oban.Worker

  @impl true
  def perform(%Oban.Job{}) do
    groups = Groups.list_unreleased_groups()

    Enum.reduce_while(groups, :ok, fn group, _acc ->
      case Groups.update_group(group, %{released: true}) do
        {:ok, group} ->
          case %{group_id: group.id}
               |> Niceties.Workers.SendReleaseEmails.new()
               |> Oban.insert() do
            {:ok, _job} ->
              {:cont, :ok}

            {:error, reason} ->
              {:halt,
               {:error, "Failed to enqueue email job for group #{group.id}: #{inspect(reason)}"}}
          end

        {:error, _changeset} ->
          {:halt, {:error, "Failed to release group #{inspect(group.id)}"}}
      end
    end)
  end
end
