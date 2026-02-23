defmodule PersonalDriveApiWeb.Router do
  use PersonalDriveApiWeb, :router
  use Pow.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PersonalDriveApiWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :pow_require do
    plug Pow.Plug.Session
  end

  scope "/" do
    pipe_through :browser

    pow_routes()
  end

  scope "/", PersonalDriveApiWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", PersonalDriveApiWeb do
    pipe_through [:api, :pow_require]

    # Files
    get "/files", FileController, :index
    get "/files/:id", FileController, :show
    post "/files/folder", FileController, :create_folder
    post "/files/upload", FileController, :upload
    post "/files/presigned", FileController, :presigned_upload
    post "/files/confirm", FileController, :confirm_upload
    get "/files/:id/download", FileController, :download_url
    delete "/files/:id", FileController, :delete

    # Sharing
    post "/files/:file_id/share", ShareController, :share
    get "/shared", ShareController, :shared_with_me
    get "/shared/by-me", ShareController, :shared_by_me
    delete "/shared/:id", ShareController, :unshare

    # Usage
    get "/usage", UsageController, :show
  end

  # Public API (registration, login, magic link)
  scope "/api/v1", PersonalDriveApiWeb do
    pipe_through :api

    get "/health", HealthController, :show
    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login
    post "/auth/logout", AuthController, :logout
    get "/auth/me", AuthController, :me
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:personal_drive_api, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PersonalDriveApiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
