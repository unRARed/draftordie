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
 "encrypted_password": "$2a$12$0v0D.DK4rxjH6gG4sWYI5eQxkvE1sKx4XG1okhILSlnM944cQhxna"
})
user.save(validate: false)
16.times{ FactoryBot.create(:user) }

puts "Seeding players..."
# generate players JSON with:
# RefreshPlayerPoolJob.perform_now
JSON.parse(File.read("db/seeds/2023/football.json")).each do |p|
  Player.create!(
    name: p["name"],
    team: p["team"],
    position: p["position"],
    bye_week: p["bye_week"],
    scraped_at: p["scraped_at"],
  )
end

puts "Seeding drafts..."
draft = FactoryBot.create(:draft, :max, user: user)
draft.users << User.last(16)
