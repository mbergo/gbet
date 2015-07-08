class Round
  include Mongoid::Document

  field :name, type: String
  field :kind, type: Symbol, default: :sum
  field :order, type: Integer
  field :opened_for_bets, type: Boolean, default: true
  field :closes_at, type: Time
  field :processed_at, type: Time

  belongs_to :championship
  has_many :matches, autosave: true

  validates :kind, inclusion: { in: [:eliminate, :sum] }
  validates :championship, presence: true
  default_scope -> { asc(:order) }

  before_save :update_closes_at

  def as_json(options={})
    attrs = super(only: [:name, :order])
    attrs.merge!({
      id: _id.to_s,
      closes_at: closes_at.try(:iso8601),
      open: opened_for_bets
    })
    attrs.merge!({ matches: matches }) if options[:include_matches]
    attrs
  end

  def bet_for(user: nil)
    Bet.find_or_create_by(round: self, user: user)
  end

  private

  def update_closes_at
    if opened_for_bets?
      first_match_date = matches.map(&:date).compact.min
      if first_match_date.present? && first_match_date.future?
        self.closes_at = first_match_date.advance(:minutes => -5)
      end
    end
  end

end
