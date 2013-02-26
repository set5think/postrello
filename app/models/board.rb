class Board < ActiveRecord::Base
  belongs_to :organization
  has_many :cards
  has_many :lists

  def add_lists
    trello_board = Trello::Board.find(self.trello_id)
    lists = trello_board.lists
    lists.each do |list|
      l = List.find_or_initialize_by_trello_id(list.attributes[:id])
      if l.new_record?
        l.name = list.attributes[:name]
        l.closed = list.attributes[:closed]
        l.board_id = self.id
        l.position = list.attributes[:pos]
        l.save
      end
      l.add_cards
    end
  end

  def add_cards
    trello_board = Trello::Board.find(self.trello_id)
    trello_cards = trello_board.cards
    trello_cards.each do |card|
      c = Card.find_or_initialize_by_trello_id(card.attributes[:id])
      if c.new_record?
        c.short_id = card.attributes[:short_id]
        c.name = card.attributes[:name]
        c.description = card.attributes[:description]
        c.due_date = card.attributes[:due]
        c.closed = card.attributes[:closed]
        c.url = card.attributes[:url]
        c.board_id = self.id
        c.save
      end
    end
  end
end
