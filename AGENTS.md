# AGENTS.md

## Cursor Cloud specific instructions

Quiz Me is a Rails 6.1 + Vue 2 (Webpacker) Bible-character guessing game backed by PostgreSQL. Ruby 3.3.0 is installed via rbenv and is already on `PATH`; system PostgreSQL 16 is installed.

### Services

- **PostgreSQL** must be running before any Rails command. It is not auto-started on boot — start it with `sudo pg_ctlcluster 16 main start`. A superuser role named `ubuntu` (the OS user) already exists, so `config/database.yml` connects with no username/password over the local socket.
- **Rails server**: `bin/dev` (Puma on port 3000). `bin/dev` sets `NODE_OPTIONS=--openssl-legacy-provider`, required for Webpack 4 under modern Node.
- **Webpack dev server**: `bin/webpack-dev-server` (port 3035) must run in a separate terminal during development so JS/Vue packs compile; the legacy OpenSSL flag is set automatically by the script. Without it, the page loads but the Vue app will not be served from the dev server.

### Tests

- Run with `bin/rails test`. The test DB schema is not auto-maintained here; if you see `PG::UndefinedTable`, load it once with `RAILS_ENV=test bin/rails db:schema:load`.
- Known pre-existing repo bug (not an environment issue): `test/fixtures/games.yml` references a `games` table that was renamed to `guess_subject_games` by migration `20220701181452_change_games_to_guess_subject_games.rb`. Because `test_helper.rb` uses `fixtures :all`, every test errors during fixture load until that stale fixture is fixed. Do not treat this as a setup failure.

### Other notes

- No linter is configured (no RuboCop/ESLint).
- `bin/rails db:seed` (re)loads questions and Bible characters from `lib/seeds/questions.csv`.
