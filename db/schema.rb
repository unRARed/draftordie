# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_08_05_023213) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "drafts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "slug"
    t.integer "round_count"
    t.integer "user_count"
    t.integer "selection_seconds"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", default: "", null: false
    t.boolean "is_paused", default: false, null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.string "access_code"
    t.index ["user_id"], name: "index_drafts_on_user_id"
  end

  create_table "pairings", force: :cascade do |t|
    t.text "context"
    t.bigint "user_id", null: false
    t.string "pairable_type", null: false
    t.bigint "pairable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "context_value"
    t.index ["pairable_type", "pairable_id"], name: "index_pairings_on_pairable"
    t.index ["user_id"], name: "index_pairings_on_user_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.string "team"
    t.string "position"
    t.integer "bye_week"
    t.datetime "scraped_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rounds", force: :cascade do |t|
    t.bigint "draft_id", null: false
    t.integer "number", null: false
    t.boolean "is_reversed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.index ["draft_id"], name: "index_rounds_on_draft_id"
  end

  create_table "selections", force: :cascade do |t|
    t.bigint "round_id", null: false
    t.bigint "user_id", null: false
    t.bigint "player_id"
    t.integer "pick_number"
    t.string "write_in_name"
    t.string "write_in_position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.bigint "draft_id", null: false
    t.index ["draft_id"], name: "index_selections_on_draft_id"
    t.index ["player_id"], name: "index_selections_on_player_id"
    t.index ["round_id"], name: "index_selections_on_round_id"
    t.index ["user_id"], name: "index_selections_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "time_zone", default: "America/Los_Angeles", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "drafts", "users"
  add_foreign_key "pairings", "users"
  add_foreign_key "rounds", "drafts"
  add_foreign_key "selections", "drafts"
  add_foreign_key "selections", "players"
  add_foreign_key "selections", "rounds"
  add_foreign_key "selections", "users"

  create_view "view_draft_progression_candidates", sql_definition: <<-SQL
      SELECT DISTINCT ON (drafts.id) drafts.id AS draft_id,
      drafts.slug AS draft_slug,
      current_selection.pick_number AS current_pick_number,
      ((current_selection.player_id IS NOT NULL) OR ((current_selection.write_in_name IS NOT NULL) AND (current_selection.write_in_position IS NOT NULL)) OR ((current_selection.started_at + ((drafts.selection_seconds)::double precision * 'PT1S'::interval)) < LOCALTIMESTAMP)) AS is_selected,
      prior_selection.id AS prior_selection_id,
      current_selection.id AS current_selection_id,
      next_selection.id AS next_selection_id
     FROM ((((drafts
       JOIN rounds ON ((drafts.id = rounds.draft_id)))
       JOIN selections current_selection ON (((current_selection.draft_id = drafts.id) AND (current_selection.started_at IS NOT NULL) AND (current_selection.ended_at IS NULL))))
       LEFT JOIN selections prior_selection ON (((prior_selection.draft_id = drafts.id) AND (prior_selection.pick_number IS NOT NULL) AND (prior_selection.pick_number = (current_selection.pick_number - 1)))))
       LEFT JOIN selections next_selection ON (((next_selection.draft_id = drafts.id) AND (next_selection.pick_number IS NOT NULL) AND (next_selection.pick_number = (current_selection.pick_number + 1)))))
    WHERE ((drafts.started_at IS NOT NULL) AND (drafts.is_paused = false));
  SQL
end
