defmodule PersonalDriveApi.ResendMailer do
  @moduledoc """
  Resend mailer for sending magic link emails.
  """
  alias Resend

  @from_email "Personal Drive <onboarding@resend.dev>"

  def send_magic_link(email, magic_link) do
    {:ok, _} =
      Resend.Emails.send(%{
        to: email,
        from: @from_email,
        subject: "Sign in to Personal Drive",
        html: """
        <!DOCTYPE html>
        <html>
          <body>
            <h1>Welcome to Personal Drive</h1>
            <p>Click the button below to sign in:</p>
            <a href="#{magic_link}" style="background-color: #007bff; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px;">Sign In</a>
            <p>Or copy this link: #{magic_link}</p>
            <p>This link expires in 15 minutes.</p>
          </body>
        </html>
        """
      })
  end

  def send_welcome_email(email) do
    {:ok, _} =
      Resend.Emails.send(%{
        to: email,
        from: @from_email,
        subject: "Welcome to Personal Drive",
        html: """
        <!DOCTYPE html>
        <html>
          <body>
            <h1>Welcome to Personal Drive!</h1>
            <p>Your account has been created successfully.</p>
            <p>Start uploading and organizing your files today.</p>
          </body>
        </html>
        """
      })
  end
end
