# Quiz Me

A Bible-character guessing game built with Rails and Vue. The app picks a character (from a pool of subjects) and you narrow it down by answering yes / no / not sure questions—solo, with friends in a shared room, or as host of a private multiplayer game. Games are limited to 10 questions.

**Stack:** Ruby on Rails 6.1, PostgreSQL, Vue 2, Vuetify, Webpacker, Action Cable (multiplayer).

## Prerequisites

- Ruby **3.3.0** (see `.ruby-version`)
- Node **≥ 16** and Yarn
- PostgreSQL

## Local setup

```bash
git clone https://github.com/eanugent/quizme.git
cd quizme

bundle install
yarn install

bin/rails db:prepare
bin/rails db:seed
```

`db:seed` loads questions and subjects from `lib/seeds/questions.csv`.

### Running the app

Development uses Webpacker’s dev server for JavaScript. Use two terminals:

```bash
# Terminal 1 — Rails
bin/dev
```

```bash
# Terminal 2 — Webpack dev server (Webpack 4 + Node 17+ need legacy OpenSSL)
bin/webpack-dev-server
```

Open [http://localhost:3000](http://localhost:3000).

Alternatively, run `bin/setup` once to install gems, prepare the database, and clear logs.

### Tests

```bash
bin/rails test
```

## Question data

Seed data lives in `lib/seeds/questions.csv`. Each row is a question; columns prefixed with `_` are Bible characters, with answer values `1` (yes), `2` (no), or `3` (not sure). Re-running `bin/rails db:seed` replaces data per game type found in the CSV.

## Deployment (Heroku)

Production deploys by pushing to the Heroku Git remote:

```bash
git push heroku main
```

Heroku app remote:

```text
https://git.heroku.com/quizme-bible.git
```

If the Heroku remote is not configured yet:

```bash
git remote add heroku https://git.heroku.com/quizme-bible.git
```

After the first deploy (or when migrations change), run on Heroku:

```bash
heroku run rails db:migrate
heroku run rails db:seed   # when question data should be refreshed
```

Heroku provides `DATABASE_URL` for PostgreSQL. Ensure `RAILS_MASTER_KEY` is set in Heroku config if you rely on encrypted credentials. Assets are precompiled during the build (`rails assets:precompile` / Webpacker production compile).

Multiplayer uses Action Cable; production is configured to use the PostgreSQL adapter for Cable (`config/cable.yml`).

## Project layout

| Path | Purpose |
|------|---------|
| `app/javascript/` | Vue app (`app.vue`, `quiz-me.vue`) |
| `app/models/pick_subject_game.rb` | Solo / multiplayer “pick subject” game logic |
| `app/channels/game_channel.rb` | Real-time multiplayer updates |
| `lib/seeds/questions.csv` | Question and character seed data |
| `config/routes.rb` | API routes under `pick_subject/` and `guess_subject/` |

## License

GPL-3.0 — see [LICENSE](LICENSE).
