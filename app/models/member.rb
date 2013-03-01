class Member < ActiveRecord::Base
  has_and_belongs_to_many :organizations
  has_and_belongs_to_many :cards,
                          :foreign_key => 'member_ids',
                          :finder_sql => proc {"SELECT * FROM cards WHERE ARRAY[#{id}] <@ member_ids"}

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

