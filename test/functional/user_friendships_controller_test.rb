require 'test_helper'

class UserFriendshipsControllerTest < ActionController::TestCase
  context "#index" do
    context "when not logged in" do
      should "redirect to the log in page" do
        get :index
        assert_response :redirect
        assert_redirected_to login_path
      end
    end

    context "when logged in" do
      setup do
        @friendship1 = create(:pending_user_friendship, user: users(:martha), friend: create(:user, first_name: "Pending", last_name: "Friend"))
       @friendship2 = create(:accepted_user_friendship, user: users(:martha), friend: create(:user, first_name: "Active", last_name: "Friend"))

        sign_in users(:martha)
        get :index
      end

      should "get the index page without error" do
        assert_response :success
      end

      should "assign user_friendships" do
        assert assigns(:user_friendships)
      end

      should "display friends names" do
        assert_match /Pending/, response.body
        assert_match /Active/, response.body
      end
    end
  end

  context "#new" do
    context "when not logged in" do
      should "redirect to the log in page" do
        get :new
        assert_response :redirect
      end
    end

    context "when logged in" do
      setup do
        sign_in users(:martha)
      end

      should "get new and return success" do
        get :new
        assert_response :success
      end

      should "set a flash error if the friend_id params is missing" do
        get :new, {}
        assert_equal "Friend required", flash[:error]
      end

      should "display the friend's name" do
        get :new, friend_id: users(:joseph)
        assert_match /#{users(:joseph).full_name}/, response.body
      end

      should "assign a user friendship in the controller" do
        get :new, friend_id: users(:joseph)
        assert assigns(:user_friendship)
      end

      should "assign a user friendship in the controller to the correct friend" do
        get :new, friend_id: users(:joseph)
        assert_equal users(:joseph), assigns(:user_friendship).friend
      end

      should "assign a user friendship in the controller to currently logged in user" do
        get :new, friend_id: users(:joseph)
        assert_equal users(:martha), assigns(:user_friendship).user
      end

      should "return a 404 status if no friend is found" do
        get :new, friend_id: 'invalid'
        assert_response :not_found
      end

      should "ask if you really want to friend the user" do
        get :new, friend_id: users(:joseph)
        assert_match /Do you really want to friend #{users(:joseph).full_name}?/, response.body
      end
    end
  end

  context "#create" do
    context "when not logged in" do
      should "redirect to log in page" do
        get :new
        assert_response :redirect
        assert_redirected_to login_path
      end
    end
  end

  context "when logged in" do
    setup do
      sign_in users(:martha)
    end

    context "with no friend id" do
      setup do
        post :create
      end

      should "return a flash error message" do
        assert !flash[:error].empty?
      end

      should "redirect to the site root" do
        assert_redirected_to root_path
      end
    end

    context "successfully" do
      should "create two user friendships" do
        assert_difference 'UserFriendship.count', 2 do
          post :create, user_friendship: { friend_id: users(:mary).profile_name }
        end
      end
    end

    context "with a valid friend id" do
      setup do
        post :create, user_friendship: { friend_id: users(:joseph) }
      end

      should "assign a friend object" do
        assert assigns[:friend]
        assert_equal users(:joseph), assigns(:friend)
      end

      should "assign a user_friendship object" do
        assert assigns(:user_friendship)
        assert_equal users(:martha), assigns(:user_friendship).user
        assert_equal users(:joseph), assigns(:user_friendship).friend
      end

      should "create a friendship" do
        assert users(:martha).pending_friends.include?(users(:joseph))
      end

      should "redirect to the profile page of the friend" do
        assert_response :redirect
        assert_redirected_to profile_path(users(:joseph))
      end

      should "set flash success message" do
        assert flash[:success]
        assert_equal "Friend request sent.", flash[:success]
      end
    end
  end

  context "#accept" do
    context "when not logged in" do
      should "redirect to the log in page" do
        put :accept, id: 1
        assert_response :redirect
        assert_redirected_to login_path
      end
    end

    context "when logged in" do
      setup do
        @friend = create(:user)
        @user_friendship = create(:pending_user_friendship, user: users(:martha), friend: @friend)
        create(:pending_user_friendship, friend: users(:martha), user: @friend)
        sign_in users(:martha)
        put :accept, id: @user_friendship
        @user_friendship.reload
      end

      should "assign a user friendship" do
        assert assigns(:user_friendship)
        assert_equal @user_friendship, assigns(:user_friendship)
      end

      should "update the state to accepted" do
        assert_equal 'accepted', @user_friendship.state
      end

      should "create a flash success message" do
        assert_equal "You are now friends with #{@user_friendship.friend.first_name}", flash[:success]
      end
    end
  end

  context "#edit" do
    context "when not logged in" do
      should "redirect to the log in page" do
        get :edit, id: 1
        assert_response :redirect
      end
    end

    context "when logged in" do
      setup do
        @user_friendship = create(:pending_user_friendship, user: users(:martha))
        sign_in users(:martha)
        get :edit, id: @user_friendship
      end

      should "get edit and return success" do
        get :edit, id: @user_friendship
        assert_response :success
      end

      should "assign to user_friendship" do
        assert assigns(:user_friendship)
      end

      should "assign to friend" do
        assert assigns(:friend)
      end
    end
  end

  context "#destroy" do
    context "when not logged in" do
      should "redirect to the log in page" do
        delete :destroy, id: 1
        assert_response :redirect
        assert_redirected_to login_path
      end
    end
  
    context "when logged in" do
      setup do
        @friend = create(:user)
        @user_friendship = create(:accepted_user_friendship, friend: @friend, user: users(:martha))
        create(:accepted_user_friendship, friend: users(:martha), user: @friend)
        sign_in users(:martha)
        @user_friendship.reload
      end

      should "delete the mutual friendship" do
        assert_difference 'UserFriendship.count', -2 do
          delete :destroy, id: @user_friendship
        end
      end

      should "set the flash"do
        delete :destroy, id: @user_friendship
        assert_equal "Friendship destroyed", flash[:success]
      end
    end
  end
end
