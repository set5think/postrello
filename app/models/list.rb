class List < ActiveRecord::Base
  belongs_to :board
  belongs_to :organization
  has_many :cards

  def add_or_update_cards
    trello_list = Trello::List.find(self.trello_id)
    trello_cards = trello_list.cards
    trello_cards.each do |card|
      checksum = Digest::MD5.hexdigest(card.attributes.to_s)
      c = Card.find_or_initialize_by_trello_id(card.attributes[:id])
      if c.new_record? || checksum != c.hexdigest
        c.short_id = card.attributes[:short_id]
        c.name = card.attributes[:name]
        c.description = card.attributes[:description]
        c.due_date = card.attributes[:due]
        c.closed = card.attributes[:closed]
        c.url = card.attributes[:url]
        c.board_id = self.board_id
        c.list_id = self.id
        c.position = card.attributes[:pos]
        c.member_ids = []
        unless card.attributes[:member_ids].empty?
          card.attributes[:member_ids].each do |member_trello_id|
            if Member.member_exists?(member_trello_id)
              c.member_ids << Member.get_member_id(member_trello_id)
            end
          end
        end
        c.hexdigest = checksum
        c.save
      end
    end
  end

end
