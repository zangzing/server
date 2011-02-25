require "reserved_user_names"

# call this literally as
# rake reserved:magic[username]

namespace :reserved do
  desc 'make a magic name to allow user to pass a reserve name'
  task :magic, :name do |t, args|
    puts "name = #{args.name}"
    name = args.name
    magic_name = ReservedUserNames.make_unlock_name(name)
    puts "Verified as " + ReservedUserNames.verify_unlock_name(magic_name, true)
    puts "Magic Name for #{name} => #{magic_name}"
  end
end

