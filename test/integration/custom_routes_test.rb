require 'test_helper'

class CustomRoutesTest < ActionDispatch::IntegrationTest

  test "that /login route opens login page" do
    get "/login"
    assert_response :success
  end

  test "that /logout route opens log out page" do
    get "/logout"
    assert_response :redirect
    assert_redirected_to '/'
  end

  test "that /register route opens sign up page" do
    get "/register"
    assert_response :success
  end

  test "that a profile page works" do
    get "/MarthaChumo"
    assert_response :success
  end

end
