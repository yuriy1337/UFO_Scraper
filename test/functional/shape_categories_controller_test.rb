require 'test_helper'

class ShapeCategoriesControllerTest < ActionController::TestCase
  setup do
    @shape_category = shape_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:shape_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create shape_category" do
    assert_difference('ShapeCategory.count') do
      post :create, :shape_category => @shape_category.attributes
    end

    assert_redirected_to shape_category_path(assigns(:shape_category))
  end

  test "should show shape_category" do
    get :show, :id => @shape_category.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @shape_category.to_param
    assert_response :success
  end

  test "should update shape_category" do
    put :update, :id => @shape_category.to_param, :shape_category => @shape_category.attributes
    assert_redirected_to shape_category_path(assigns(:shape_category))
  end

  test "should destroy shape_category" do
    assert_difference('ShapeCategory.count', -1) do
      delete :destroy, :id => @shape_category.to_param
    end

    assert_redirected_to shape_categories_path
  end
end
