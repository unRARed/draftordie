class AddContextValueToPairings < ActiveRecord::Migration[7.0]
  def change
    add_column :pairings, :context_value, :string

    Pairing.all.each do |pairing|
      team_name = ("A".."Z").to_a.sample(6).join.capitalize
      pairing.update!(
        context: "Draft Team Name",
        context_value: team_name
      )
    end
  end
end
