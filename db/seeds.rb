# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

puts "Seeding users..."
user = User.new({
  email: "kuwlade@yahoo.com",
  # password: "password",
 "encrypted_password": "$2a$12$0v0D.DK4rxjH6gG4sWYI5eQxkvE1sKx4XG1okhILSlnM944cQhxna"
})
user.save(validate: false)
20.times{ FactoryBot.create(:user) }

puts "Seeding players..."
# generate players JSON with:
# RefreshPlayerPoolJob.perform_now
Player.import_json("db/seeds/2023/football.json")

puts "Seeding drafts..."
[8, 10, 12, 14, 16, 20].each do |count|
  draft = FactoryBot.create(:draft,
    :max, user: user,
    selection_seconds: [30, 60].sample
  )
  draft.users << User.first(count)
end
