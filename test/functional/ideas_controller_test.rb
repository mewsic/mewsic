require File.dirname(__FILE__) + '/../test_helper'

class IdeasControllerTest < ActionController::TestCase
  fixtures :tracks, :instruments
  
  def test_index
    get :index
    assert_response :success
    
    assert assigns(:newest)
    assert assigns(:coolest)
    assert assigns(:top_rated)
    assert assigns(:most_engaging)
    assert assigns(:ideas_instruments)
    assert assigns(:instruments)
  end

  def test_newest
    xhr :get, :newest
    assert_response :success

    assert assigns(:newest)
  end
  
  def test_coolest
    xhr :get, :coolest
    assert_response :success

    assert assigns(:coolest)
  end
  
  def test_by_instrument
    xhr :get, :by_instrument, :instrument_id => instruments(:guitar).id
    assert_response :success
    assert assigns(:instrument)
    assert assigns(:ideas)

    xhr :get, :by_instrument
    assert_response :success
    assert assigns(:ideas_instruments)
  end
  
end
