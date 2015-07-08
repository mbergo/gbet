Fabricator(:battle) do
  host(fabricator: :user)
  guest(fabricator: :user)
  round
  league
end
