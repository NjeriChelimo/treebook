require 'test_helper'

class StatusTest < ActiveSupport::TestCase

  test "that a status requires content" do
    status = Status.new
    assert !status.save
    assert !status.errors[:content].empty?
  end

  test "that the status content is at least 2 letters long" do
    status = Status.new
    status.content = "M"
    assert !status.save
    assert !status.errors[:content].empty?
  end

  test "that the status has a user id" do
    status = Status.new
    status.content = "Hello"
    assert !status.save
    assert !status.errors[:user_id].empty?
  end

end
