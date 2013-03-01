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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130228183252) do

  create_table "boards", :force => true do |t|
    t.text     "trello_id",                          :null => false
    t.text     "name",                               :null => false
    t.text     "description"
    t.boolean  "closed",          :default => false, :null => false
    t.text     "url",                                :null => false
    t.integer  "organization_id",                    :null => false
    t.text     "hexdigest",                          :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "boards", ["trello_id"], :name => "boards_trello_id_key", :unique => true

  create_table "cards", :force => true do |t|
    t.text     "trello_id",                      :null => false
    t.integer  "short_id",                       :null => false
    t.text     "name",                           :null => false
    t.text     "description"
    t.datetime "due_date"
    t.boolean  "closed",      :default => false, :null => false
    t.text     "url",                            :null => false
    t.integer  "board_id",                       :null => false
    t.integer  "member_ids",                                     :array => true
    t.integer  "list_id",                        :null => false
    t.integer  "position",                       :null => false
    t.text     "hexdigest",                      :null => false
    t.float    "points"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "cards", ["trello_id"], :name => "cards_trello_id_key", :unique => true

  create_table "checklist_items", :force => true do |t|
    t.text     "trello_id",                       :null => false
    t.text     "name",                            :null => false
    t.boolean  "complete",     :default => false, :null => false
    t.text     "item_type",                       :null => false
    t.integer  "position",                        :null => false
    t.integer  "checklist_id",                    :null => false
    t.integer  "card_id",                         :null => false
    t.integer  "board_id",                        :null => false
    t.text     "hexdigest",                       :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "checklist_items", ["trello_id"], :name => "checklist_items_trello_id_key", :unique => true

  create_table "checklists", :force => true do |t|
    t.text     "trello_id",                      :null => false
    t.text     "name",                           :null => false
    t.text     "description"
    t.boolean  "closed",      :default => false, :null => false
    t.text     "url"
    t.boolean  "complete",    :default => false, :null => false
    t.integer  "card_id",                        :null => false
    t.integer  "board_id",                       :null => false
    t.text     "hexdigest",                      :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "checklists", ["trello_id"], :name => "checklists_trello_id_key", :unique => true

  create_table "lists", :force => true do |t|
    t.text     "trello_id",                     :null => false
    t.text     "name",                          :null => false
    t.boolean  "closed",     :default => false, :null => false
    t.integer  "board_id",                      :null => false
    t.integer  "position",                      :null => false
    t.text     "hexdigest",                     :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "lists", ["trello_id"], :name => "lists_trello_id_key", :unique => true

  create_table "members", :force => true do |t|
    t.text     "trello_id",  :null => false
    t.text     "username",   :null => false
    t.text     "full_name"
    t.text     "avatar_id"
    t.text     "bio"
    t.text     "url"
    t.text     "hexdigest",  :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "members", ["trello_id"], :name => "members_trello_id_key", :unique => true

  create_table "members_organizations", :id => false, :force => true do |t|
    t.integer "member_id"
    t.integer "organization_id"
  end

  create_table "organizations", :force => true do |t|
    t.text     "trello_id",    :null => false
    t.text     "name",         :null => false
    t.text     "display_name", :null => false
    t.text     "description"
    t.text     "url",          :null => false
    t.text     "hexdigest",    :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "organizations", ["trello_id"], :name => "organizations_trello_id_key", :unique => true

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email",                                  :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
