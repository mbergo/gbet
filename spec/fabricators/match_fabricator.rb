Fabricator(:match) do
  date { 1.day.from_now }
  host_score { 2 }
  guest_score { 0 }

  host(fabricator: :team)
  guest(fabricator: :team)
end
