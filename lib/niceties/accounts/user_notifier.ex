defmodule Niceties.Accounts.UserNotifier do
  import Swoosh.Email

  alias Niceties.Mailer
  alias Niceties.Accounts.User

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Niceties", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.name},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to log in with a magic link.

  Sends a confirmation email for users who have not yet confirmed their account,
  and a standard login email for returning users.
  """
  def deliver_login_instructions(user, url, group_name \\ nil) do
    case user do
      %User{confirmed_at: nil} -> deliver_invitation_instructions(user, url, group_name)
      _ -> deliver_magic_link_instructions(user, url)
    end
  end

  defp deliver_magic_link_instructions(user, url) do
    deliver(user.email, "Log in instructions", """

    ==============================

    Hi #{user.name},

    You can log into your account by visiting the URL below:

    #{url}

    If you didn't request this email, please ignore this.

    ==============================
    """)
  end

  defp deliver_invitation_instructions(user, url, group_name) do
    group_line =
      if group_name, do: "You've been invited to join #{group_name} on Niceties", else: "You've been invited to Niceties"

    deliver(user.email, "You've been invited to join Niceties!", """

    ==============================

    Hi #{user.name},

    #{group_line} - a place to share and receive kind words with your group.

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  def deliver_release_notification(user, url) do
    deliver(user.email, "Your group's niceties have been released!", """

    ==============================

    Hi #{user.name},

    We wanted to let you know that your niceties have been released. You can view them at:

    #{url}

    Enjoy 😊

    ==============================
    """)
  end
end
