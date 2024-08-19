Draft or Die
============

A live, in-room fantasy sports draft board — Rails app for running a real-time,
big-screen fantasy draft without auto-drafters or ranking-list predictability.

Instead of drafting off a laptop or an auto-draft queue, a Draft Admin runs
the draft on a shared screen while participants make picks in real time
(remote participants can join too). Drafts can be paused, no-shows just miss
their pick instead of getting auto-drafted for them, and picks not on the
consensus rankings can still be written in.

Built with Rails 7, Hotwire (Turbo + Stimulus), Devise, and a handful of
[Scenic](https://github.com/scenic-views/scenic) SQL views for the draft
board's live state — deployed on Fly.io.

Fly.io
------

- Connect to `rails console` on the remote server:
  `rails fly:console`

Other Commands
--------------

- Generate a SQL view/model:
  `rails generate scenic:model data_selections_for_bulk_edit`
