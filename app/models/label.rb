class Label < ActiveRecord::Base
  belongs_to :board

  def cards
    Card.find_by_sql("SELECT * FROM cards WHERE ARRAY[#{self.id}] <@ label_ids")
  end

  class << self

    def find_or_create_and_return(board_id, trello_label)
      checksum = Digest::MD5.hexdigest(trello_label.attributes.to_s + board_id.to_s)
      label = find_or_initialize_by_board_id_and_color(board_id, trello_label.attributes[:color])
      if label.new_record?
        label.value = trello_label.attributes[:name]
        label.hexdigest = checksum
        label.save
      end
      label
    end

  end
end
