require 'test_helper'

class ImportControllerTest < ActionController::TestCase
  test "should get changes" do
    get :changes
    assert_response :success
  end

end
