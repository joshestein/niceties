defmodule NicetiesWeb.UserLive.Settings do
  use NicetiesWeb, :live_view

  alias Niceties.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="text-center">
        <.header>
          Account Settings
          <:subtitle>Manage your account email address</:subtitle>
        </.header>
      </div>

      <.form for={@email_form} id="email_form" phx-submit="update_email" phx-change="validate_email">
        <.input
          field={@email_form[:email]}
          type="email"
          label="Email"
          autocomplete="username"
          spellcheck="false"
          required
        />
        <.button variant="primary" phx-disable-with="Changing...">Change Email</.button>
      </.form>

      <div class="fieldset mb-2">
        <span class="label mb-1">Photo</span>
        <%= if @current_scope.user.avatar do %>
          <img
            src={~p"/users/#{@current_scope.user.id}/avatar"}
            alt="Your current avatar"
            class="size-16 rounded-full object-cover"
          />
        <% end %>
      </div>

      <div id="avatar-cropper" phx-hook="AvatarCropper">
        <div id="avatar-canvas-wrapper" phx-update="ignore" style="display: inline-block; position: relative;">
          <canvas
            id="avatar-canvas"
            width="400"
            height="400"
            style="display: none; cursor: grab;"
          >
          </canvas>
          <div
            id="avatar-handle-se"
            style="display: none; position: absolute; width: 14px; height: 14px; border-right: 2.5px solid #0D99FF; border-bottom: 2.5px solid #0D99FF; cursor: se-resize;"
          ></div>
        </div>
        <.form for={%{}} id="avatar_form" phx-submit="upload_avatar" phx-change="validate_avatar">
          <.live_file_input upload={@uploads.avatar} />
          <input type="hidden" id="crop-x" name="crop_x" value="" />
          <input type="hidden" id="crop-y" name="crop_y" value="" />
          <input type="hidden" id="crop-size" name="crop_size" value="" />
          <.button type="submit" variant="primary">Upload photo</.button>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_scope.user, token) do
        {:ok, _user} ->
          put_flash(socket, :info, "Email changed successfully.")

        {:error, _} ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    email_changeset = Accounts.change_user_email(user, %{}, validate_unique: false)

    socket =
      socket
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> allow_upload(:avatar,
        accept: ~w(.jpg .jpeg .png .webp),
        max_entries: 1,
        max_file_size: 5_000_000
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_email", params, socket) do
    %{"user" => user_params} = params

    email_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_email(user_params, validate_unique: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form)}
  end

  def handle_event("update_email", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user

    case Accounts.change_user_email(user, user_params) do
      %{valid?: true} = changeset ->
        Accounts.deliver_user_update_email_instructions(
          Ecto.Changeset.apply_action!(changeset, :insert),
          user.email,
          &url(~p"/users/settings/confirm-email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info)}

      changeset ->
        {:noreply, assign(socket, :email_form, to_form(changeset, action: :insert))}
    end
  end

  # phx-change needed for file uploading even though event handler does nothing
  def handle_event("validate_avatar", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("upload_avatar", params, socket) do
    user = socket.assigns.current_scope.user
    crop = parse_crop(params)

    result =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
        outcome =
          with {:ok, image} <- Image.open(path),
               {:ok, cropped} <- maybe_crop(image, crop),
               {:ok, resized} <- Image.thumbnail(cropped, 128, fit: :cover, height: 128),
               {:ok, binary} <- Image.write(resized, :memory, suffix: ".webp") do
            {:ok, binary}
          end

        {:ok, outcome}
      end)

    case result do
      [{:ok, binary}] when is_binary(binary) ->
        case Accounts.update_user_avatar(user, %{avatar: binary}) do
          {:ok, _user} ->
            {:noreply, put_flash(socket, :info, "Avatar updated.")}

          {:error, _changeset} ->
            {:noreply, put_flash(socket, :error, "Failed to save avatar.")}
        end

      _ ->
        {:noreply, put_flash(socket, :error, "Upload failed.")}
    end
  end

  defp parse_crop(%{"crop_x" => x, "crop_y" => y, "crop_size" => size}) do
    with {x, ""} <- Integer.parse(x),
         {y, ""} <- Integer.parse(y),
         {size, ""} <- Integer.parse(size),
         true <- size > 0 do
      {x, y, size}
    else
      _ -> nil
    end
  end

  defp parse_crop(_), do: nil

  defp maybe_crop(image, nil), do: {:ok, image}
  defp maybe_crop(image, {x, y, size}), do: Image.crop(image, x, y, size, size)
end
