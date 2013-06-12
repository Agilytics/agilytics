require 'test_helper'

class SprintsControllerTest < ActionController::TestCase
  setup do
    @sprint = sprints(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sprints)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sprint" do
    assert_difference('Sprint.count') do
      post :create, sprint: { closed: @sprint.closed, end_date: @sprint.end_date, have_all_changes: @sprint.have_all_changes, have_processed_all_changes: @sprint.have_processed_all_changes, name: @sprint.name, pid: @sprint.pid, start_date: @sprint.start_date, velocity: @sprint.velocity }
    end

    assert_redirected_to sprint_path(assigns(:sprint))
  end

  test "should show sprint" do
    get :show, id: @sprint
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sprint
    assert_response :success
  end

  test "should update sprint" do
    put :update, id: @sprint, sprint: { closed: @sprint.closed, end_date: @sprint.end_date, have_all_changes: @sprint.have_all_changes, have_processed_all_changes: @sprint.have_processed_all_changes, name: @sprint.name, pid: @sprint.pid, start_date: @sprint.start_date, velocity: @sprint.velocity }
    assert_redirected_to sprint_path(assigns(:sprint))
  end

  test "should destroy sprint" do
    assert_difference('Sprint.count', -1) do
      delete :destroy, id: @sprint
    end

    assert_redirected_to sprints_path
  end
end
