class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :profile_name

  has_many :statuses

  validates :last_name, presence: true
  validates :first_name, presence: true
  validates :profile_name, presence: true,
                           uniqueness: true,
                           format: {
                            with: /a-zA-Z0-9_-/,
                            message: "Must be formatted correctly."
                           }

  def full_name
    first_name + " " + last_name
  end

end
