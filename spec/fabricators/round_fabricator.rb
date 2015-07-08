Fabricator(:round) do
  name { Faker::Name.name }
  kind { :sum }
  order { 1 }
  opened_for_bets { true }

  matches { [
    Fabricate(:match, host_score: 2, guest_score: 0),
    Fabricate(:match, host_score: 0, guest_score: 1),
    Fabricate(:match, host_score: 0, guest_score: 3),
    Fabricate(:match, host_score: 0, guest_score: 0),
    Fabricate(:match, host_score: 3, guest_score: 3)
  ] }

end
