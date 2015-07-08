class User
  include Mongoid::Document
  include Mongoid::Timestamps

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :confirmable, :omniauthable, :omniauth_providers => [:facebook]

  field :name, type: String
  field :avatar, type: String

  ## Omniauth
  field :provider, type: String
  field :oauth_token, type: String
  field :oauth_expires_at, type: String

  ## Database authenticatable
  field :email,              type: String
  field :password, type: String
  field :encrypted_password, type: String

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  field :confirmation_token,   type: String
  field :confirmed_at,         type: Time
  field :confirmation_sent_at, type: Time
  field :unconfirmed_email,    type: String # Only if using reconfirmable

  has_and_belongs_to_many :leagues, class_name: "League", inverse_of: :members

  validates :email, uniqueness: {:allow_blank => true}

  def self.from_id(uid)
    find_or_initialize_by(:_id => uid).tap do |user|
      user.password = Devise.friendly_token[0,20]
      user.save!
      user.confirm!
    end
  end

  def as_json(options={})
    { id: _id.to_s }
  end

  def set_bet_for(match, host_score, guest_score)
    if match.round.opened_for_bets?
      bet = match.round.bet_for(user: self)
      bet_match = bet.bet_matches.find_or_create_by(match: match)
      bet_match.host_score = host_score
      bet_match.guest_score = guest_score
      bet.save!
    else
      false
    end
  end
end
