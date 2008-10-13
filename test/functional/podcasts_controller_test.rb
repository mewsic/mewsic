require File.dirname(__FILE__) + '/../test_helper'
require 'rexml/document'

class PodcastsControllerTest < ActionController::TestCase
  fixtures :users, :songs, :mbands, :mband_memberships

  def test_user_pcast
    get :pcast, :user_id => users(:quentin).id
    assert_response :success
    
    xml = REXML::Document.new(@response.body)
    assert_equal 1, REXML::XPath.match(xml, "//pcast").size
    assert_equal 0, REXML::XPath.match(xml, "//non_existing_element").size
  end

  def test_user_podcast
    get :show, :user_id => users(:quentin).id
    assert_response :success

    assert_podcast @response.body
  end

  def test_mband_podcast
    get :show, :mband_id => mbands(:quentin_mband).id
    assert_response :success

    assert_podcast @response.body
  end

private

  def assert_podcast(text, nitems = 19)
    xml = REXML::Document.new(text)
    assert_equal 1, REXML::XPath.match(xml, "//channel").size
    assert_equal nitems, REXML::XPath.match(xml, "//title").size
    assert_equal 0, REXML::XPath.match(xml, "//non_existing_element").size
  end

end
