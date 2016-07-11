# Apientry

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Configure your database *(see below)*
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Database configuration

To configure your PostgreSQL database, you can do either one of two things:

  * Create an account with username: `postgres`, password: `postgres` and give it database creation permissions. *(recommended for dev and test)*

    ```sh
    $ psql foo  # where `foo` is any existing database
    psql (4.9.5)
    Type "help" for help.

    foo=# create user postgres with password "postgres";
    foo=# alter user postgres with createdb;
    ```

  * Alternatively, just set `DATABASE_URL` to whatever you need. *(recommended for production)*

    ```
    export DATABASE_URL="postgres://user:pass@localhost:5432/phoenix_dev"
    ```

  * Create your database

    ```
    mix ecto.create
    ```

## Sample commands

`/publisher` - basic keyword search. `-v` *(verbose)* shows the HTTP response headers.

```sh
curl -v "https://sandbox.apientry.com/publisher?keyword=nikon"
```

The output is compressed. You can use [jsonpp](https://jmhodges.github.io/jsonpp/) to format your text.

```sh
curl "https://sandbox.apientry.com/publisher?keyword=nikon" | jsonpp
```

`-H "Accept: text/xml"` returns XML responses.

```sh
curl -v "https://sandbox.apientry.com/publisher?keyword=nikon" -H "Accept: text/xml"
```

`/dryrun/publisher` - lets you inspect what goes on in a request.

```sh
curl -v "https://sandbox.apientry.com/dryrun/publisher?keyword=nikon&visitorIPAddress=8.8.8.8&trackingId=800537"
```

I also recommend using [httpie](http://httpie.org/) instead of curl. It supports auto-formatting of JSON/XML responses, colors, and many other features.

## Setting up production

An [Ansible playbook](http://docs.ansible.com/) is available to set up the stack on bare Ubuntu servers.

```sh
cd ansible
less hosts   # change/add hosts to deploy to here
make setup
```

## Deploying

[Edeliver](https://github.com/boldpoker/edeliver) is used to deploy.

```sh
less .deliver/config  # see PRODUCTION_HOSTS and BUILD_HOSTS
mix edeliver build release -V --branch=master
mix edeliver deploy upgrade to production
```

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: http://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
