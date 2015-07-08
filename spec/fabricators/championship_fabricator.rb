Fabricator(:championship) do
  transient n_rounds: 1

  name { Faker::Name.name }
  rounds { |attrs| (1..attrs[:n_rounds]).map { |i| Fabricate.build(:round, order: i) } }
  current_round_id { |attrs| attrs[:rounds].first.id }
end
