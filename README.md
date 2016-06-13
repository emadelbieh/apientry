# Apientry

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Configure your database`*`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

To configure your database, you can do either one of two things:

  * Create an account with username: `postgres`, password: `postgres` and give it database creation permissions. (recommended)

    ```
    $ psql
    psql (4.9.5)
    Type "help" for help.
    
    foo=# create user postgres with password "postgres";
    foo=# alter user postgres with createdb;
    ```

  * Alternatively, just set `DATABASE_URL` to whatever you need:

    ```
    export DATABASE_URL="postgres://user:pass@localhost:5432/phoenix_dev"
    ```

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: http://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
