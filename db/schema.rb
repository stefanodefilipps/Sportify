# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180519085913) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "giocas", force: :cascade do |t|
    t.string "squadra"
    t.string "ruolo"
    t.bigint "user_id"
    t.bigint "pp_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pp_id"], name: "index_giocas_on_pp_id"
    t.index ["squadra", "ruolo", "pp_id"], name: "index_giocas_on_squadra_and_ruolo_and_pp_id", unique: true
    t.index ["user_id"], name: "index_giocas_on_user_id"
  end

  create_table "matches", force: :cascade do |t|
    t.integer "punt1"
    t.integer "punt2"
    t.string "campo"
    t.date "data"
    t.time "ora"
    t.float "lat"
    t.float "long"
    t.bigint "creatore_id"
    t.integer "tipo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creatore_id"], name: "index_matches_on_creatore_id"
  end

  create_table "membros", force: :cascade do |t|
    t.string "ruolo"
    t.bigint "team_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id", "ruolo"], name: "index_membros_on_team_id_and_ruolo", unique: true
    t.index ["team_id"], name: "index_membros_on_team_id"
    t.index ["user_id"], name: "index_membros_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "tipo"
    t.date "data"
    t.time "ora"
    t.string "msg"
    t.bigint "sender_id"
    t.bigint "receiver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receiver_id"], name: "index_notifications_on_receiver_id"
    t.index ["sender_id"], name: "index_notifications_on_sender_id"
  end

  create_table "pars", force: :cascade do |t|
    t.bigint "notification_id"
    t.bigint "match_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_pars_on_match_id"
    t.index ["notification_id"], name: "index_pars_on_notification_id"
  end

  create_table "pps", force: :cascade do |t|
    t.bigint "match_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_pps_on_match_id"
  end

  create_table "pts", force: :cascade do |t|
    t.bigint "match_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_pts_on_match_id"
  end

  create_table "s", force: :cascade do |t|
    t.string "ruolo"
    t.bigint "pt_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pt_id"], name: "index_s_on_pt_id"
    t.index ["ruolo", "pt_id"], name: "index_s_on_ruolo_and_pt_id", unique: true
    t.index ["user_id"], name: "index_s_on_user_id"
  end

  create_table "sqs", force: :cascade do |t|
    t.bigint "notificatio_id"
    t.bigint "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notificatio_id"], name: "index_sqs_on_notificatio_id"
    t.index ["team_id"], name: "index_sqs_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "nome"
    t.bigint "capitano_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["capitano_id"], name: "index_teams_on_capitano_id"
  end

  create_table "tts", force: :cascade do |t|
    t.bigint "match_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_tts_on_match_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "nome"
    t.string "cognome"
    t.text "desc"
    t.string "img"
    t.float "voto"
    t.string "ruolo1"
    t.string "ruolo2"
    t.string "nick"
    t.string "uid"
    t.string "provider"
    t.string "token"
  end

end
