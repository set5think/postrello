namespace :trello do
  namespace :organization do
    desc "add or update organization data"
    task :upsert, [:name] => [:environment] do |t, args|
      Organization.add_or_update_organization(args[:name])
      org = Organization.find_by_name(args[:name])
      org.add_or_update_members
      org.add_or_update_boards
      org.boards.each do |board|
        board.add_or_update_labels
      end
      org.boards.each do |board|
        board.add_or_update_lists
      end
      org.cards.each do |card|
        card.add_or_update_labels
      end
      org.cards.each do |card|
        card.add_or_update_checklists
      end
    end
  end
end
