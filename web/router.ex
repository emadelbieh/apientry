defmodule Apientry.Router do
  use Apientry.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :secure do
    plug BasicAuth, Application.get_env(:apientry, :basic_auth)
  end

  pipeline :api do
    plug :accepts, ["json", "xml"]
    plug CORSPlug
  end

  scope "/", Apientry do
    pipe_through :browser
    pipe_through :secure
    get "/", PageController, :index

    resources "/feeds", FeedController

    put "/publishers/:id/regenerate_key", PublisherController, :regenerate
    resources "/publishers", PublisherController do
      resources "/tracking_ids", TrackingIdController
    end
  end

  scope "/", Apientry do
    pipe_through :api
    get "/publisher", SearchController, :search
    get "/redirect/:fragment", RedirectController, :show

    options "/publisher", SearchController, :search # for cors

    get "/__healthcheck", HealthCheckController, :index
    get "/loaderio-b86e3ad1127445bea97f60fc77392f9c", LoaderVerificationController, :show_b86e3ad1
    get "/loaderio-b86e3ad1127445bea97f60fc77392f9c.html", LoaderVerificationController, :show_b86e3ad1
    get "/loaderio-b86e3ad1127445bea97f60fc77392f9c.txt", LoaderVerificationController, :show_b86e3ad1
  end

  scope "/", Apientry do
    pipe_through :api
    pipe_through :secure
    get "/dryrun/publisher", SearchController, :dry_search
  end
end
