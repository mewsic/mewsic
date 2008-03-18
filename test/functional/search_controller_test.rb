require 'rexml/document'

require File.dirname(__FILE__) + '/../test_helper'

class SearchControllerTest < ActionController::TestCase

  # Replace this with your real tests.
  def test_should_show_search
    get :show, :id => 'jimy hendrix', :format => 'xml'
    assert_response :success
    xml = REXML::Document.new(@response.body)
    assert_equal 1, REXML::XPath.match(xml, "//songs").size
    assert_equal 0, REXML::XPath.match(xml, "//non_existing_element").size
  end
  
end
