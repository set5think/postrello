class Organization < ActiveRecord::Base
  has_and_belongs_to_many :members
  has_many :boards
  has_many :cards, :through => :boards
  has_many :lists, :through => :boards

  def add_or_update_members
    trello_org = Trello::Organization.find(self.name)
    trello_members = trello_org.members
    trello_members.each do |member|
      checksum = Digest::MD5.hexdigest(member.attributes.to_s)
      m = Member.find_or_initialize_by_trello_id(member.attributes[:id])
      if m.new_record? || checksum != m.hexdigest
        m.username = member.attributes[:username]
        m.full_name = member.attributes[:full_name]
        m.avatar_id = member.attributes[:avatar_id]
        m.bio = member.attributes[:bio]
        m.url = member.attributes[:url]
        m.email = member.attributes[:email]
        m.hexdigest = checksum
        m.save
      end
      unless m.in_organization?(self)
        m.organizations << self
      end
    end
  end

  def add_or_update_boards
    trello_org = Trello::Organization.find(self.name)
    trello_boards = trello_org.boards
    trello_boards.each do |board|
      checksum = Digest::MD5.hexdigest(board.attributes.to_s)
      b = Board.find_or_initialize_by_trello_id(board.attributes[:id])
      if b.new_record? || checksum != b.hexdigest
        b.name = board.attributes[:name]
        b.description = board.attributes[:description]
        b.closed = board.attributes[:closed]
        b.url = board.attributes[:url]
        b.organization_id = self.id
        b.hexdigest = checksum
        b.save
      end
    end
  end

  private

  def self.add_or_update_organization(org_name)
    trello_org = Trello::Organization.find(org_name)
    checksum = Digest::MD5.hexdigest(trello_org.attributes.to_s)
    org = self.find_or_initialize_by_trello_id(trello_org.attributes[:id])
    if org.new_record? || checksum != org.hexdigest
      org.trello_id = trello_org.attributes[:id]
      org.name = trello_org.attributes[:name]
      org.display_name = trello_org.attributes[:display_name]
      org.description = trello_org.attributes[:description]
      org.url = trello_org.attributes[:url]
      org.hexdigest = checksum
      org.save
    end
  end
end
