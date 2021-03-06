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
    get "/cloudflare", PageController, :cloudflare_values

    resources "/geos", GeoController
    resources "/accounts", AccountController
    resources "/ebay_api_keys", EbayApiKeyController
    resources "/publisher_api_keys", PublisherApiKeyController
    resources "/feeds", FeedController
    resources "/tracking_ids", TrackingIdController
    resources "/publisher_sub_ids", PublisherSubIdController
    resources "/blacklist", BlacklistController
    
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
    get "/search", SearchController, :extension_search
    get "/publisher", SearchController, :search
    get "/alpha/publisher", SearchController, :search_rerank
    get "/coupons", CouponSearchController, :search
    get "/merchants", MerchantController, :index
    get "/dos", SearchController, :search_rerank_coupons
    get "/publisher/:endpoint", SearchController, :search
    get "/redirect/:fragment", RedirectController, :show
    get "/blacklisted", BlacklistController, :query
    get "/vssubids", PublisherSubIdController, :query

    get "/subid/generate", SubIdController, :generate
    options "/publisher", SearchController, :search # for cors

    get "/__healthcheck", HealthCheckController, :index

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
