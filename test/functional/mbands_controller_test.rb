require File.dirname(__FILE__) + '/../test_helper'

class MbandsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:mbands)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_mband
    assert_difference('Mband.count') do
      post :create, :mband => { }
    end

    assert_redirected_to mband_path(assigns(:mband))
  end

  def test_should_show_mband
    get :show, :id => mbands(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => mbands(:one).id
    assert_response :success
  end

  def test_should_update_mband
    put :update, :id => mbands(:one).id, :mband => { }
    assert_redirected_to mband_path(assigns(:mband))
  end

  def test_should_destroy_mband
    assert_difference('Mband.count', -1) do
      delete :destroy, :id => mbands(:one).id
    end

    assert_redirected_to mbands_path
  end
end
