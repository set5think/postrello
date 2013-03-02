class List < ActiveRecord::Base
  belongs_to :board
  belongs_to :organization
  has_many :cards

  def add_or_update_cards
    trello_list = Trello::List.find(self.trello_id)
    trello_cards = trello_list.cards({:filter => [:all]})
    trello_cards.each do |card|
      checksum = Digest::MD5.hexdigest(card.attributes.to_s)
      c = Card.find_or_initialize_by_trello_id(card.attributes[:id])
      if c.new_record? || checksum != c.hexdigest
        c.short_id = card.attributes[:short_id]
        c.name = card.attributes[:name]
        c.description = card.attributes[:description]
        c.due_date = card.attributes[:due]
        c.last_active = card.attributes[:last_active_date]
        c.closed = card.attributes[:closed]
        c.url = card.attributes[:url]
        c.board_id = self.board_id
        c.list_id = self.id
        c.position = card.attributes[:pos]
        unless card.attributes[:member_ids].empty?
          c.member_ids = []
          card.attributes[:member_ids].each do |member_trello_id|
            if Member.member_exists?(member_trello_id)
              c.member_ids << Member.get_member_id(member_trello_id)
            end
          end
        end
        unless card.labels.empty?
          c.label_ids = []
          card.labels.each do |label|
            l = Label.find_or_create_and_return(self.board_id, label)
            c.label_ids << l.id
          end
        end
        c.hexdigest = checksum
        c.save
      end
    end
  end

end
