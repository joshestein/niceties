defmodule NicetiesWeb.UserLive.Settings do
  use NicetiesWeb, :live_view

  alias Niceties.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="pt-4 font-light">
        <p class="tracking-[0.2em] text-warm/65 text-sm uppercase">
          Account settings
        </p>
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
        <div id="avatar-cropper" phx-hook="AvatarCropper">
          <div
            id="avatar-preview-circle"
            class="size-20 sm:size-28 bg-warm/10 flex shrink-0 items-center justify-center overflow-hidden rounded-full"
          >
            <%= if @current_scope.user.avatar || @avatar_ts do %>
              <img
                src={"/users/#{@current_scope.user.id}/avatar" <> if(@avatar_ts, do: "?v=#{@avatar_ts}", else: "")}
                alt="Your current avatar"
                class="size-20 sm:size-28 object-cover"
              />
            <% else %>
              <span class="text-warm/60 text-sm font-light tracking-widest">
                {initials(@current_scope.user)}
              </span>
            <% end %>
          </div>
          <div
            id="avatar-canvas-wrapper"
            phx-update="ignore"
            style="display: inline-block; position: relative;"
          >
            <canvas
              id="avatar-canvas"
              width="400"
              height="400"
              style="display: none; cursor: grab; touch-action: none;"
            >
            </canvas>
            <div
              id="avatar-handle-se"
              style="display: none; position: absolute; width: 14px; height: 14px; border-right: 2.5px solid #0D99FF; border-bottom: 2.5px solid #0D99FF; cursor: se-resize; touch-action: none;"
            >
            </div>
          </div>
          <.form for={%{}} id="avatar_form" phx-submit="upload_avatar">
            <input id="avatar-file-input" type="file" accept=".jpg,.jpeg,.png,.webp" class="sr-only" />
            <input type="hidden" id="avatar-data" name="avatar_data" value="" />
            <label for="avatar-file-input" class="btn btn-primary btn-soft">Choose photo</label>
            <.button id="avatar-upload-btn" type="submit" variant="primary" style="display:none">Upload photo</.button>
          </.form>
        </div>
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
      |> assign(:avatar_ts, nil)

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

  def handle_event("upload_avatar", %{"avatar_data" => data_url}, socket) do
    user = socket.assigns.current_scope.user

    with "data:image/webp;base64," <> base64 <- data_url,
         true <- byte_size(base64) < 500_000,
         {:ok, binary} <- Base.decode64(base64),
         <<"RIFF", _::binary-size(4), "WEBP", _::binary>> <- binary do
      case Accounts.update_user_avatar(user, %{avatar: binary}) do
        {:ok, _user} ->
          ts = System.os_time(:millisecond)

          {:noreply,
           socket
           |> assign(:avatar_ts, ts)
           |> push_event("avatar_uploaded", %{ts: ts})
           |> put_flash(:info, "Avatar updated.")}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Failed to save avatar.")}
      end
    else
      _ -> {:noreply, put_flash(socket, :error, "Upload failed.")}
    end
  end
end
