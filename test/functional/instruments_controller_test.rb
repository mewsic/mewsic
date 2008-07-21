require File.dirname(__FILE__) + '/../test_helper'

class InstrumentsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def test_index_xml_should_response_succcess
    get :index, :format => 'xml'
    assert_response :success
    assert assigns(:instruments)
  end

  def test_index_html_should_response_redirect
    get :index, :format => 'html'
    assert_response :redirect
  end
end
