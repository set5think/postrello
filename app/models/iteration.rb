class Iteration < ActiveRecord::Base

  attr_accessible :start_date, :end_date, :estimated_points

  def total_value
    self.connection.execute(
      "WITH cards_from_past AS (
         SELECT ch.*
         FROM postrello.cards_histories ch
         JOIN postrello.board_settings bs USING (board_id)
         WHERE bs.settings ? 'done_queue'::TEXT
         AND (bs.settings->'done_queue')::INTEGER = ch.list_id
         AND ch.updated_at::DATE BETWEEN '#{self.start_date}' AND '#{self.end_date}'
       ),
       current_cards AS (
         SELECT c.*
         FROM postrello.cards c
         JOIN postrello.board_settings bs USING (board_id)
         WHERE bs.settings ? 'done_queue'::TEXT
         AND (bs.settings->'done_queue')::INTEGER = c.list_id
         AND c.updated_at::DATE BETWEEN '#{self.start_date}' AND '#{self.end_date}'
       ),
       summed_up_past_cards AS (
         SELECT COUNT(*) AS cards, SUM(points) AS points
         FROM cards_from_past
       ),
       summed_up_current_cards AS (
         SELECT COUNT(*) AS cards, SUM(points) AS points
         FROM current_cards
       )
       SELECT pc.cards + cc.cards AS cards, pc.points + cc.points AS points
       FROM summed_up_past_cards pc, summed_up_current_cards cc"
    )
  end

end
