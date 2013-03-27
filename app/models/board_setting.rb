class BoardSetting < ActiveRecord::Base

  belongs_to :board
  serialize :settings , ActiveRecord::Coders::Hstore
  attr_accessible :board_id, :done_queue, :working_queue, :backlog_queue
  attr_accessor :done_queue, :working_queue, :backlog_queue
  validate :unique_queues, :on => :create

  def unique_queues
    if (settings[:working_queue] == (settings[:done_queue] || settings[:backlog_queue])) ||
       (settings[:done_queue] == (settings[:working_queue] || settings[:backlog_queue])) ||
       (settings[:backlog_queue] == (settings[:done_queue] || settings[:working_queue]))
      errors.add(:settings, 'Your queues must be unique!')
    end
  end

  def done_queue
    self.settings['done_queue']
  end

  def working_queue
    self.settings['working_queue']
  end

  def backlog_queue
    self.settings['backlog_queue']
  end

end
