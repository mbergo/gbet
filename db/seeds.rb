gamebet_user = User.find_or_initialize_by(id: "fb_1436853629883247", email: "gamebet@gamebet.com.br")
if gamebet_user.new_record?
  gamebet_user.name = "Gamebet"
  gamebet_user.password = Devise.friendly_token[0,20]
  gamebet_user.save!
  puts "Gamebet user created"
else
  puts "Gamebet user already created"
end

[
  { name: "Copa do Brasil 2014", year: 2014, slug: "copa_do_brasil", capacity: 32, minimum: 16},
  { name: "Campeonato Brasileiro 2014", year: 2014, slug: "brasileiro", capacity: 20, minimum: 10},
].each do |championship|
  c = Championship.find_or_create_by(name: championship[:name])

  1.upto(10) do |i|
    league = League.find_or_initialize_by(name: "Grupo #{i}", championship: c)
    league.championship = c
    league.capacity = championship[:capacity]
    league.minimum = championship[:minimum]
    league.save!
  end

  Dir[File.expand_path("./championships/#{championship[:slug]}/#{championship[:year]}/*.txt", File.dirname(__FILE__))].each do |file|
    data = JSON.parse File.read(file)

    # teams
    data["referencias"]["equipes"].each do |id, equipe|
      team = Team.find_or_create_by(name: equipe["nome_popular"])
      team.update_attributes shield: equipe["escudos"]["60x60"] if team.shield.blank?
    end

    # matches
    data["resultados"]["jogos"].each do |jogo|
      round = c.rounds.find_or_create_by(name: "Rodada #{jogo["rodada"]}", order: jogo["rodada"].to_i)
      host = Team.where(name: data["referencias"]["equipes"][jogo["equipe_mandante_id"].to_s]["nome_popular"]).first
      guest = Team.where(name: data["referencias"]["equipes"][jogo["equipe_visitante_id"].to_s]["nome_popular"]).first

      match = round.matches.where(round: round, host: host, guest: guest).first
      match ||= round.matches.create!(round: round, host: host, guest: guest)
      match.date = Time.parse "#{jogo["data_realizacao"]}T#{jogo["hora_realizacao"]} -03:00"
      match.host_score = jogo["placar_oficial_mandante"]
      match.guest_score = jogo["placar_oficial_visitante"]
      match.save!
      round.save!
    end
  end
end

[Championship, Round, Team, Match].map(&:count)
