class AddEmailToMembers < ActiveRecord::Migration
  def change
    add_column :members, :email, :text
  end
end
