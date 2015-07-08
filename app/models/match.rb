class Match
  include Mongoid::Document

  field :date, type: DateTime
  field :host_score, type: Integer
  field :guest_score, type: Integer

  belongs_to :round
  belongs_to :host, class_name: "Team", inverse_of: nil
  belongs_to :guest, class_name: "Team", inverse_of: nil

  validates :round, presence: true
  validates :host, presence: true
  validates :guest, presence: true

  accepts_nested_attributes_for :host
  accepts_nested_attributes_for :guest

  def result
    if host_score == guest_score
      :draw
    elsif host_score > guest_score
      :host_wins
    else
      :guest_wins
    end
  end

  def as_json(options={})
    attrs = super(only: [:host_score, :guest_score])
    attrs.merge!({
      id: _id.to_s,
      date: date.try(:iso8601),
      host: host,
      guest: guest
    })
    attrs
  end
end
