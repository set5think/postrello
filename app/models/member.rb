class Member < ActiveRecord::Base
  has_and_belongs_to_many :organizations

  def cards
    Card.find_by_sql("SELECT * FROM cards WHERE ARRAY[#{self.id}] <@ member_ids")
  end

  class << self

    def get_member_id(_trello_id)
      _id = connection.execute("SELECT get_member_id('#{_trello_id}')")
      _id[0]['get_member_id'].to_i rescue -1
    end

    def member_exists?(_trello_id)
      get_member_id(_trello_id) > 0
    end
  end
end

