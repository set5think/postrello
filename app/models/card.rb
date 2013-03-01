class Card < ActiveRecord::Base
  belongs_to :board
  belongs_to :list
  belongs_to :organization
  has_many :checklists
  has_many :checklist_items

  def add_or_update_checklists
    trello_card = Trello::Card.find(self.trello_id)
    trello_checklists = trello_card.checklists
    unless trello_checklists.empty?
      trello_checklists.each do |checklist|
        checksum = Digest::MD5.hexdigest(checklist.attributes.to_s)
        ch = Checklist.find_or_initialize_by_trello_id(checklist.attributes[:id])
        if ch.new_record? || checksum != ch.hexdigest
          ch.name = checklist.attributes[:name]
          ch.description = checklist.attributes[:description]
          ch.closed = checklist.attributes[:closed] == nil ? false : true
          ch.url = checklist.attributes[:url]
          ch.card_id = self.id
          ch.board_id = self.board.id
          ch.hexdigest = checksum
          ch.save
          ch.add_or_update_checklist_items(checklist.attributes[:check_items])
        end
      end
    end
  end

end
