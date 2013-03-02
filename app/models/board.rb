class Board < ActiveRecord::Base
  belongs_to :organization
  has_many :cards
  has_many :lists
  has_many :labels

  def add_or_update_labels
    trello_board = Trello::Board.find(self.trello_id)
    labels = trello_board.labels
    checksum = Digest::MD5.hexdigest(labels.attributes.to_s + self.id.to_s)
    labels.attributes.each do |color, value|
      l = Label.find_or_initialize_by_board_id_and_color(self.id, color.to_s)
      if l.new_record? || checksum != l.hexdigest
        l.value = value.blank? ? nil : value
        l.hexdigest = checksum
        l.save
      end
    end
  end

  def add_or_update_lists
    trello_board = Trello::Board.find(self.trello_id)
    lists = trello_board.lists({:filter => [:all]})
    lists.each do |list|
      checksum = Digest::MD5.hexdigest(list.attributes.to_s)
      l = List.find_or_initialize_by_trello_id(list.attributes[:id])
      if l.new_record? || checksum != l.hexdigest
        l.name = list.attributes[:name]
        l.closed = list.attributes[:closed]
        l.board_id = self.id
        l.position = list.attributes[:pos]
        l.hexdigest = checksum
        l.save
      end
      l.add_or_update_cards
    end
  end

  # questioning the ability to add cards via the board level.  Boards contain lists, which contain cards.
  # Adding cards through the board level means you could potentially have cards on lists that you don't
  # know about yet.  By going board -> list -> card when speaking strictly about data import, the benefit
  # is that you never have to worry about that.

  def add_or_update_cards
    trello_board = Trello::Board.find(self.trello_id)
    trello_cards = trello_board.cards({:filter => [:all]})
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
        c.board_id = self.id
        unless card.attributes[:member_ids].empty?
          card.attributes[:member_ids].each do |member_trello_id|
            if Member.member_exists?(member_trello_id)
              c.member_ids << Member.get_member_id(member_trello_id)
            end
          end
        end
        unless card.labels.empty?
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
