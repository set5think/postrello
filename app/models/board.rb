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
        c.closed = card.attributes[:closed]
        c.url = card.attributes[:url]
        c.board_id = self.id
        c.hexdigest = checksum
        c.save
      end
    end
  end
end
