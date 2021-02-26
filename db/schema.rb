# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_02_25_014544) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.string "about"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "junior_enterprises", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "members", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "about"
    t.bigint "junior_enterprise_id", null: false
    t.integer "position"
    t.boolean "validated"
    t.string "name"
    t.index ["email"], name: "index_members_on_email", unique: true
    t.index ["junior_enterprise_id"], name: "index_members_on_junior_enterprise_id"
    t.index ["reset_password_token"], name: "index_members_on_reset_password_token", unique: true
  end

  create_table "post_categories", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "post_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_post_categories_on_category_id"
    t.index ["post_id"], name: "index_post_categories_on_post_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "link"
    t.float "rating"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "season_posts", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.bigint "season_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["post_id"], name: "index_season_posts_on_post_id"
    t.index ["season_id"], name: "index_season_posts_on_season_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.string "name"
    t.bigint "tv_serie_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tv_serie_id"], name: "index_seasons_on_tv_serie_id"
  end

  create_table "tv_serie_categories", force: :cascade do |t|
    t.bigint "tv_serie_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_tv_serie_categories_on_category_id"
    t.index ["tv_serie_id"], name: "index_tv_serie_categories_on_tv_serie_id"
  end

  create_table "tv_series", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "owner_id"
    t.boolean "is_admin"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "members", "junior_enterprises"
  add_foreign_key "post_categories", "categories"
  add_foreign_key "post_categories", "posts"
  add_foreign_key "season_posts", "posts"
  add_foreign_key "season_posts", "seasons"
  add_foreign_key "seasons", "tv_series", column: "tv_serie_id"
  add_foreign_key "tv_serie_categories", "categories"
  add_foreign_key "tv_serie_categories", "tv_series", column: "tv_serie_id"
end
