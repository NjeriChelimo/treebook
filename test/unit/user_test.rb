require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should have_many(:user_friendships)
  should have_many(:friends)

  test "a user should enter a first name" do
    user = User.new
    assert !user.save
    assert !user.errors[:first_name].empty?
  end

  test "a user should enter a last name" do
    user = User.new
    assert !user.save
    assert !user.errors[:last_name].empty?
  end

  test "a user should enter a profile name" do
    user = User.new
    assert !user.save
    assert !user.errors[:profile_name].empty?
  end

  test "a user should enter a unique profile name" do
    user = User.new
    user.profile_name = users(:martha).profile_name
    assert !user.save
    assert !user.errors[:profile_name].empty?
  end

  test "a user should enter profile name without spaces" do
    user = User.new(first_name: 'martha', last_name: 'chumo', email: 'marthachumo2@gmail.com')
    user.profile_name = "My Profile Name With Spaces"
    assert !user.save
    assert !user.errors[:profile_name].empty?
    assert user.errors[:profile_name].include?("Must be formatted correctly.")
  end

  test "a user should have a correctly formatted profile name" do
    user = User.new(first_name: 'martha', last_name: 'chumo', email: 'marthachumo2@gmail.com')
    user.profile_name = 'martha1'
    user.password = user.password_confirmation = 'asdfasdf'
    assert user.valid?
  end

  test "that no error is raised when trying to access a friend list" do
    assert_nothing_raised do
      users(:martha).friends
    end
  end

  test "that creating friendships on a user works" do
    users(:martha).pending_friends << users(:mary)
    users(:martha).pending_friends.reload
    assert users(:martha).pending_friends.include?(users(:mary))
  end

  test "that calling to_param on a user return hye profile_name" do
    assert_equal "MarthaChumo", users(:martha).to_param
  end

end
