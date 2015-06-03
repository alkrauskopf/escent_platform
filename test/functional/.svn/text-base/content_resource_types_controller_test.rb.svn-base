require 'test_helper'

class ContentResourceTypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:content_resource_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create content_resource_type" do
    assert_difference('ContentResourceType.count') do
      post :create, :content_resource_type => { }
    end

    assert_redirected_to content_resource_type_path(assigns(:content_resource_type))
  end

  test "should show content_resource_type" do
    get :show, :id => content_resource_types(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => content_resource_types(:one).to_param
    assert_response :success
  end

  test "should update content_resource_type" do
    put :update, :id => content_resource_types(:one).to_param, :content_resource_type => { }
    assert_redirected_to content_resource_type_path(assigns(:content_resource_type))
  end

  test "should destroy content_resource_type" do
    assert_difference('ContentResourceType.count', -1) do
      delete :destroy, :id => content_resource_types(:one).to_param
    end

    assert_redirected_to content_resource_types_path
  end
end
