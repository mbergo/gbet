class Team
  include Mongoid::Document

  field :name, type: String
  field :shield, type: String

  validates :name, presence: true, uniqueness: true

  def as_json(options={})
    attrs = super(only: [:name, :shield])
    attrs.merge!(id: _id.to_s)
    attrs
  end
end
