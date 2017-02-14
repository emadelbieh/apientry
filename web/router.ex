defmodule Apientry.Router do
  use Apientry.Web, :router
  use Plug.ErrorHandler
  alias Apientry.ErrorReporter

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

    resources "/merchants", MerchantController
    resources "/geos", GeoController
    resources "/accounts", AccountController
    resources "/ebay_api_keys", EbayApiKeyController
    resources "/publisher_api_keys", PublisherApiKeyController
    resources "/feeds", FeedController
    resources "/tracking_ids", TrackingIdController

    get  "/assign/step1", AssignmentController, :step1
    post "/assign/step2", AssignmentController, :step2
    post "/assign/step3", AssignmentController, :step3
    post "/assign/assign", AssignmentController, :assign
    patch "/assign/:id/unassign", AssignmentController, :unassign

    put "/publishers/:id/regenerate_key", PublisherController, :regenerate
    resources "/publishers", PublisherController do
      resources "/tracking_ids", TrackingIdController
    end
  end

  scope "/", Apientry do
    pipe_through :api
    get "/publisher", SearchController, :search
    get "/alpha/publisher", SearchController, :search_rerank
    get "/coupons", CouponSearchController, :search
    get "/publisher/:endpoint", SearchController, :search
    get "/redirect/:fragment", RedirectController, :show

    options "/publisher", SearchController, :search # for cors

    get "/__healthcheck", HealthCheckController, :index

    get "/loaderio-b86e3ad1127445bea97f60fc77392f9c", LoaderVerificationController, :show_b86e3ad1
    get "/loaderio-b86e3ad1127445bea97f60fc77392f9c.html", LoaderVerificationController, :show_b86e3ad1
    get "/loaderio-b86e3ad1127445bea97f60fc77392f9c.txt", LoaderVerificationController, :show_b86e3ad1
    get "/loaderio-694461ab4a923d21b45b975c4032b9ff", LoaderVerificationController, :show_694461ab
    get "/loaderio-694461ab4a923d21b45b975c4032b9ff.html", LoaderVerificationController, :show_694461ab
    get "/loaderio-694461ab4a923d21b45b975c4032b9ff.txt", LoaderVerificationController, :show_694461ab

    get "/loaderio-ed96d28cb6cb372defb0748d98689a27", LoaderVerificationController, :show_ed96d28c
    get "/loaderio-ed96d28cb6cb372defb0748d98689a27.html", LoaderVerificationController, :show_ed96d28c
    get "/loaderio-ed96d28cb6cb372defb0748d98689a27.txt", LoaderVerificationController, :show_ed96d28c

    get "/loaderio-7554f28861c6c058e54aaa267c439680", LoaderVerificationController, :show_7554f288
    get "/loaderio-7554f28861c6c058e54aaa267c439680.html", LoaderVerificationController, :show_7554f288
    get "/loaderio-7554f28861c6c058e54aaa267c439680.txt", LoaderVerificationController, :show_7554f288

    get "/loaderio-dd9715bade6eb23cec502a38f3bfa865", LoaderVerificationController, :show_dd9715ba
    get "/loaderio-dd9715bade6eb23cec502a38f3bfa865", LoaderVerificationController, :show_dd9715ba
    get "/loaderio-dd9715bade6eb23cec502a38f3bfa865", LoaderVerificationController, :show_dd9715ba

    get "/direct", SearchController, :direct
  end

  scope "/", Apientry do
    pipe_through :api
    pipe_through :secure
    get "/dryrun/publisher", SearchController, :dry_search
    get "/dryrun/publisher/:endpoint", SearchController, :dry_search
  end

  # catch all routes
  scope "/", Apientry do
    pipe_through :api
    get    "/*path", CatchAllController, :catch_all
    post   "/*path", CatchAllController, :catch_all
    put    "/*path", CatchAllController, :catch_all
    patch  "/*path", CatchAllController, :catch_all
    delete "/*path", CatchAllController, :catch_all
  end

  defp handle_errors(conn, details) do
    ErrorReporter.report(conn, details)
  end
end
