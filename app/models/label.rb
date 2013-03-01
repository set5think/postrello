class Label < ActiveRecord::Base
  belongs_to :board
  has_and_belongs_to_many :cards,
                          :foreign_key => 'label_ids',
                          :finder_sql => proc {"SELECT * FROM cards WHERE ARRAY[#{id}] <@ label_ids"}
end
