require File.dirname(__FILE__) + '/../test_helper'

class BandsAndDeejaysControllerTest < ActionController::TestCase
  fixtures :users, :mbands
   
  def test_index
    get :index
    assert_response :success
    
    assert assigns(:coolest)
    assert assigns(:best_myousicians)
    assert assigns(:prolific)
    assert assigns(:most_admired)
    assert assigns(:coolest_mbands)
    assert assigns(:newest)
    assert assigns(:most_instruments)
  end
end
