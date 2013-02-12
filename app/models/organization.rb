class Organization < ActiveRecord::Base
  has_and_belongs_to_many :members
  has_many :boards

  def add_members
    trello_org = Trello::Organization.find(self.name)
    trello_members = trello_org.members
    trello_members.each do |member|
      m = Member.find_or_initialize_by_trello_id(member.attributes[:id])
      if m.new_record?
        m.username = member.attributes[:username]
        m.full_name = member.attributes[:full_name]
        m.avatar_id = member.attributes[:avatar_id]
        m.bio = member.attributes[:bio]
        m.url = member.attributes[:url]
        m.save
      end
    end
  end

  private

  def self.add_organization(org_name)
    trello_org = Trello::Organization.find(org_name)
    org = self.find_or_initialize_by_trello_id(trello_org.attributes[:id])
    if org.new_record?
      org.trello_id = trello_org.attributes[:id]
      org.name = trello_org.attributes[:name]
      org.display_name = trello_org.attributes[:display_name]
      org.description = trello_org.attributes[:description]
      org.url = trello_org.attributes[:url]
      org.save
    end
  end
end
