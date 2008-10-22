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

    assert_template 'index'
    
  end

  def test_newest
    xhr :get, :newest
    assert_response :success
    assert_template '_newest'

    assert assigns(:newest)
  end
  
  def test_coolest
    xhr :get, :coolest
    assert_response :success
    assert_template '_coolest'

    assert assigns(:coolest)
  end
  
  def test_by_instrument
    xhr :get, :by_instrument, :instrument_id => instruments(:guitar).id
    assert_response :success
    assert assigns(:instrument)
    assert assigns(:ideas)
    assert_template 'by_instrument'

    xhr :get, :by_instrument
    assert_response :success
    assert assigns(:ideas_instruments)
    assert_template '_ideas_table'
  end
  
end
