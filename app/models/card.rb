class Card < ActiveRecord::Base
  belongs_to :board
  belongs_to :list
  belongs_to :organization
  has_many :checklists
  has_many :checklist_items

  scope :without_points, where('points IS NULL')
  scope :with_points, where('points IS NOT NULL')

  def self.average_score
    sprintf('%05.2f', self.sum('points')/self.with_points.count)
  end

  def members
    Member.find_by_sql("SELECT * FROM members WHERE id IN (SELECT unnest(member_ids) FROM cards WHERE id = #{self.id})")
  end

  def labels
    Label.find_by_sql("SELECT * FROM labels WHERE id IN (SELECT unnest(label_ids) FROM cards WHERE id = #{self.id})")
  end

  def add_or_update_labels
    trello_card = Trello::Card.find(self.trello_id)
    _labels = trello_card.labels
    unless _labels.empty?
      _labels.each do |label|
        l = Label.find_or_create_and_return(self.board_id, label)
        self.label_ids << l.id
      end
      self.save
    end
  end

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
        end
        ch.add_or_update_checklist_items(checklist.attributes[:check_items])
      end
    end
  end

end
