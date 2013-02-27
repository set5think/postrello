namespace :admin do
  desc "add admin user"
  task :add_user, [:email, :password] => [:environment] do |t, args|
    user = User.find_or_initialize_by_email(args[:email])
    if user.new_record?
      user.password = args[:password]
      user.save
    end
  end
end
