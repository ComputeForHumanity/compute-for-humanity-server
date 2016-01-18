# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160118182614) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "donations", force: :cascade do |t|
    t.datetime "created_at",                           null: false
    t.string   "transaction_id"
    t.string   "charity_name",                         null: false
    t.integer  "initial_usd_cents",    default: 0,     null: false
    t.string   "initial_usd_currency", default: "USD", null: false
    t.integer  "donated_usd_cents",    default: 0,     null: false
    t.string   "donated_usd_currency", default: "USD", null: false
    t.integer  "fee_usd_cents",        default: 0,     null: false
    t.string   "fee_usd_currency",     default: "USD", null: false
    t.string   "status"
  end

  create_table "dwolla_secrets", force: :cascade do |t|
    t.string "refresh_token",      null: false
    t.string "encrypted_pin",      null: false
    t.string "encrypted_pin_salt", null: false
    t.string "encrypted_pin_iv",   null: false
  end

  create_table "exchanges", force: :cascade do |t|
    t.datetime "created_at",                             null: false
    t.string   "transaction_id",                         null: false
    t.integer  "initial_btc_satoshis",   default: 0,     null: false
    t.string   "initial_btc_currency",   default: "BTC", null: false
    t.integer  "exchanged_usd_cents",    default: 0,     null: false
    t.string   "exchanged_usd_currency", default: "USD", null: false
    t.integer  "fee_usd_cents",          default: 0,     null: false
    t.string   "fee_usd_currency",       default: "USD", null: false
    t.datetime "payout_date",                            null: false
    t.boolean  "complete",               default: false, null: false
  end

  create_table "recruits", id: false, force: :cascade do |t|
    t.string  "uuid",                   null: false
    t.integer "n_recruits", default: 0
  end

  add_index "recruits", ["uuid"], name: "index_recruits_on_uuid", unique: true, using: :btree

end
