class Checklist < ActiveRecord::Base
  belongs_to :card
  belongs_to :board
  belongs_to :organization
  belongs_to :list
  has_many :checklist_items
  has_and_belongs_to_many :members

  def add_or_update_checklist_items(items)
    items.each do |item|
      checksum = Digest::MD5.hexdigest(item.to_s)
      i = ChecklistItem.find_or_initialize_by_trello_id(item['id'])
      if i.new_record? || checksum != i.hexdigest
        i.name = item['name']
        i.complete = item['state'] == 'incomplete' ? false : true
        i.item_type = item['type'] == nil ? 'checkbox' : item['type']
        i.position = item['pos']
        i.checklist_id = self.id
        i.card_id = self.card_id
        i.board_id = self.board_id
        i.hexdigest = checksum
        i.save
      end
    end
  end
end
