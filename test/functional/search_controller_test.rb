require File.dirname(__FILE__) + '/../test_helper'
require 'rexml/document'

class SearchControllerTest < ActionController::TestCase

  def test_should_show_xml_search
    get :show, :q => 'jimy hendrix', :format => 'xml'
    assert_response :success
    xml = REXML::Document.new(@response.body)
    assert_equal 1, REXML::XPath.match(xml, "//songs").size
    assert_equal 0, REXML::XPath.match(xml, "//non_existing_element").size
  end

  def test_should_show_html_search
    get :show, :q => 'quentin', :format => 'html'
    assert_response :success

    assert_equal 1, assigns(:users).size
    assert_equal 1, assigns(:songs).size

    get :show, :q => 'red red wine', :format => 'html'
    assert_response :success

    assert_equal 0, assigns(:users).size
    assert_equal 1, assigns(:songs).size
    assert_equal 0, assigns(:tracks).size
    assert_equal 0, assigns(:tracks).size
  end

end
