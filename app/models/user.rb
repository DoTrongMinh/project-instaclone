class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  followability

  has_many :posts
  has_many :likes
  has_many :comments
  has_one_attached :avatar
  before_create :randomize_id

  # Unfollow method
  def unfollow(user)
    followerable_relationships.where(followable_id: user.id).destroy_all
  end

  # Ransackable attributes method
  def self.ransackable_attributes(auth_object = nil)
    ["bio", "created_at", "email", "username", "updated_at"]
  end

  private

  # Randomize ID before creating a new user
  def randomize_id
    begin
      self.id = SecureRandom.random_number(1_000_000_000)
    end while User.where(id: self.id).exists?
  end


  # Set default role to :admin if the user is a new record
  enum role: [:user, :admin]
  after_initialize :set_default_role, if: :new_record?

  def set_default_role
    self.role ||= :admin
  end
end
