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

ActiveRecord::Schema[7.1].define(version: 2024_04_21_162909) do
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
    t.string "write_in_team"
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

  create_view "data_players_remaining_for_drafts", sql_definition: <<-SQL
      SELECT DISTINCT ON (d.id, pl."position", (concat(pl."position", ' ', pl.name))) pl.id,
      d.id AS draft_id,
      concat(pl.name, ' (', pl."position", ', ', pl.team, ')') AS player_data,
      concat(pl."position", ' ', pl.name) AS value_for_sort,
      (selected_players.draft_id IS NOT NULL) AS is_selected
     FROM ((((players pl
       CROSS JOIN drafts d)
       JOIN rounds r ON ((r.draft_id = d.id)))
       JOIN selections s ON ((s.round_id = r.id)))
       LEFT JOIN ( SELECT pl_1.id AS selected_player_id,
              d_1.id AS draft_id
             FROM (((players pl_1
               JOIN selections s_1 ON ((s_1.player_id = pl_1.id)))
               JOIN rounds r_1 ON ((r_1.id = s_1.round_id)))
               JOIN drafts d_1 ON ((d_1.id = r_1.draft_id)))) selected_players ON (((pl.id = selected_players.selected_player_id) AND (selected_players.draft_id = d.id))))
    ORDER BY d.id, pl."position" DESC, (concat(pl."position", ' ', pl.name));
  SQL
  create_view "data_selections_for_displays", sql_definition: <<-SQL
      SELECT DISTINCT ON (d.id, s.pick_number) s.id AS selection_id,
      d.id AS draft_id,
      r.number AS round_number,
      s.pick_number,
      s.write_in_team,
      s.write_in_position,
      s.write_in_name,
      p.context_value AS team_name,
      s.player_id,
          CASE
              WHEN ((pl.name IS NOT NULL) AND ((pl.name)::text <> ''::text)) THEN concat('(', pl."position", ', ', pl.team, ') ', pl.name)
              WHEN ((s.write_in_name IS NOT NULL) AND ((s.write_in_name)::text <> ''::text)) THEN concat('(', s.write_in_position, ', ', s.write_in_team, ') ', s.write_in_name)
              ELSE NULL::text
          END AS player_data
     FROM ((((drafts d
       JOIN rounds r ON ((r.draft_id = d.id)))
       JOIN selections s ON ((s.round_id = r.id)))
       JOIN pairings p ON (((p.pairable_id = d.id) AND ((p.pairable_type)::text = 'Draft'::text) AND (p.context = 'Draft Team Name'::text) AND (p.user_id = s.user_id))))
       LEFT JOIN players pl ON ((pl.id = s.player_id)))
    ORDER BY d.id, s.pick_number, r.number;
  SQL
  create_view "data_state_for_draft_boards", sql_definition: <<-SQL
      SELECT DISTINCT ON (drafts.id) drafts.id AS draft_id,
      drafts.slug AS draft_slug,
      current_selection.pick_number AS current_pick_number,
      CURRENT_TIMESTAMP AS now,
      (current_selection.started_at + ((drafts.selection_seconds)::double precision * 'PT1S'::interval)) AS current_selection_ends_at,
      ((current_selection.player_id IS NOT NULL) OR ((current_selection.write_in_name IS NOT NULL) AND (current_selection.write_in_position IS NOT NULL)) OR ((current_selection.started_at + ((drafts.selection_seconds)::double precision * 'PT1S'::interval)) < CURRENT_TIMESTAMP)) AS is_selected,
      prior_selection.id AS prior_selection_id,
      current_selection.id AS current_selection_id,
      COALESCE(orphan_selections.id, next_selection.id) AS next_selection_id
     FROM (((((drafts
       JOIN rounds ON ((drafts.id = rounds.draft_id)))
       LEFT JOIN selections current_selection ON (((current_selection.draft_id = drafts.id) AND (current_selection.started_at IS NOT NULL) AND (current_selection.ended_at IS NULL))))
       LEFT JOIN selections prior_selection ON (((prior_selection.draft_id = drafts.id) AND (prior_selection.pick_number IS NOT NULL) AND (prior_selection.pick_number = (current_selection.pick_number - 1)))))
       LEFT JOIN selections next_selection ON (((next_selection.draft_id = drafts.id) AND (next_selection.pick_number IS NOT NULL) AND (next_selection.pick_number = (current_selection.pick_number + 1)))))
       LEFT JOIN ( SELECT open_selections.id,
              drafts_1.id AS draft_id
             FROM (((drafts drafts_1
               JOIN rounds rounds_1 ON ((drafts_1.id = rounds_1.draft_id)))
               LEFT JOIN ( SELECT selections.id,
                      selections.round_id,
                      selections.user_id,
                      selections.player_id,
                      selections.pick_number,
                      selections.write_in_name,
                      selections.write_in_position,
                      selections.created_at,
                      selections.updated_at,
                      selections.started_at,
                      selections.ended_at,
                      selections.draft_id,
                      selections.write_in_team
                     FROM selections
                    ORDER BY selections.pick_number) started_selections ON (((started_selections.draft_id = drafts_1.id) AND (started_selections.started_at IS NOT NULL) AND (started_selections.ended_at IS NULL))))
               JOIN selections open_selections ON (((open_selections.draft_id = drafts_1.id) AND (open_selections.started_at IS NULL) AND (open_selections.ended_at IS NULL))))
            WHERE ((drafts_1.started_at IS NOT NULL) AND (drafts_1.ended_at IS NULL) AND (drafts_1.is_paused = false) AND (started_selections.id IS NULL))
            ORDER BY open_selections.pick_number
           LIMIT 1) orphan_selections ON ((orphan_selections.draft_id = drafts.id)))
    WHERE ((drafts.started_at IS NOT NULL) AND (drafts.ended_at IS NULL) AND (drafts.is_paused = false));
  SQL
end
