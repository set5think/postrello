class CreateMembersOrganizationsJoinTable < ActiveRecord::Migration
  def up
    create_table :members_organizations, :id => false do |t|
      t.integer :member_id
      t.integer :organization_id
    end
  end

  def down
    drop_table :members_organizations
  end
end
