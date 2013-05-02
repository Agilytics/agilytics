require 'test_helper'

class SprintControllerTest < ActionController::TestCase
  test "should get changes" do
    get :changes
    assert_response :success
  end

end
