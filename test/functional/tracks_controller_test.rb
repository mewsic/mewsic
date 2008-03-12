require File.dirname(__FILE__) + '/../test_helper'

class TracksControllerTest < ActionController::TestCase

  def test_index_should_response_success
    get :index
    assert_response :success
  end
  
  def test_show_should_response_success
    get :show, :id => tracks(:sax_for_let_it_be)
    assert_response :success
  end
  
  def test_show_should_raise_exception_unless_track
    begin
      get :show, :id => 0
    rescue Exception => e
      assert e.kind_of?(ActiveRecord::RecordNotFound)
    end
  end
  
end
