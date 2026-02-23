defmodule PersonalDriveApi.ResendMailer do
  @moduledoc """
  Resend mailer for sending magic link emails.
  """
  require Logger

  @from_email "Personal Drive <onboarding@resend.dev>"

  def send_magic_link(email, magic_link) do
    api_key = Application.get_env(:personal_drive_api, :resend)[:api_key]

    Logger.info("Sending magic link to #{email}")

    case Resend.Emails.send(%{
      to: email,
      from: @from_email,
      subject: "Sign in to Personal Drive",
      html: """
      <!DOCTYPE html>
      <html>
        <body style="font-family: sans-serif; padding: 20px;">
          <h1>Welcome to Personal Drive</h1>
          <p>Click the button below to sign in:</p>
          <a href="#{magic_link}" style="background-color: #E53935; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; display: inline-block;">Sign In</a>
          <p style="margin-top: 20px;">Or copy this link: <code>#{magic_link}</code></p>
          <p style="color: #666; font-size: 12px;">This link expires in 15 minutes.</p>
        </body>
      </html>
      """
    }) do
      {:ok, result} ->
        Logger.info("Magic link sent successfully: #{inspect(result)}")
        {:ok, result}

      {:error, reason} ->
        Logger.error("Failed to send magic link: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def send_welcome_email(email) do
    api_key = Application.get_env(:personal_drive_api, :resend)[:api_key]

    case Resend.Emails.send(%{
      to: email,
      from: @from_email,
      subject: "Welcome to Personal Drive",
      html: """
      <!DOCTYPE html>
      <html>
        <body style="font-family: sans-serif; padding: 20px;">
          <h1>Welcome to Personal Drive!</h1>
          <p>Your account has been created successfully.</p>
          <p>Start uploading and organizing your files today.</p>
        </body>
      </html>
      """
    }) do
      {:ok, result} ->
        {:ok, result}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
