require File.dirname(__FILE__) + '/../test_helper'
require 'rexml/document'

class SearchControllerTest < ActionController::TestCase

  fixtures :users, :songs, :tracks, :genres, :instruments

  def setup
    super
    setup_sphinx
  end

  # HTML format
  def test_should_show_html_search
    get :show, :q => 'quentin', :format => 'html'
    assert_response :success

    assert_equal 1, assigns(:users).size
    assert_equal 1, assigns(:songs).size
  end

  def test_search_by_query_string
    get :show, :q => 'red red wine', :format => 'html'
    assert_response :success

    assert_equal 0, assigns(:users).size
    assert_equal 1, assigns(:songs).size
    assert_equal 0, assigns(:tracks).size
    assert_equal 0, assigns(:ideas).size
  end

  def test_should_paginate
    xhr :get, :show, :q => 'red red wine', :format => 'html', :type => 'song', :page => 2
    assert_response :success

    assert_equal 0, assigns(:songs).size
    assert_nil assigns(:tracks)
    assert_nil assigns(:users)
    assert_nil assigns(:ideas)
  end

  # XML format
  def test_should_produce_valid_xml_file
    get :show, :q => 'jimy hendrix', :format => 'xml'
    assert_response :success
    xml = REXML::Document.new(@response.body)
    assert_equal 1, REXML::XPath.match(xml, "//songs").size
    assert_equal 0, REXML::XPath.match(xml, "//non_existing_element").size
  end

  def test_search_by_genre
    get :show, :genre => genres(:digital_hardcore).id, :format => 'xml'
    assert_response :success

    assert_not_nil assigns(:songs)
    assert assigns(:songs).all? { |s| s.genre == genres(:digital_hardcore) }
  end

  def test_search_by_bpm
    get :show, :bpm => 166, :format => 'xml'
    assert_response :success

    assert_equal 1, assigns(:songs).size
    assert_equal songs(:quentin_productions), assigns(:songs).first
    assert_equal 166, assigns(:songs).first.bpm

    assert_equal 30, assigns(:tracks).size
    assert assigns(:tracks).all? { |t| t.bpm == 166 }
  end

  def test_search_by_key
    get :show, :key => 'D', :format => 'xml'
    assert_response :success

    assert_not_nil assigns(:tracks)
    assert assigns(:tracks).all? { |t| t.tonality == 'D' }

    assert_not_nil assigns(:songs)
    assert assigns(:songs).all? { |s| s.tone == 'D' }
  end

  def test_search_by_instrument
    get :show, :instrument => instruments(:guitar).id, :format => 'xml'
    assert_response :success

    assert_not_nil assigns(:tracks)
    assert assigns(:tracks).all? { |t| t.instrument == instruments(:guitar) }
    assert_not_nil assigns(:songs)
  end

  def test_search_by_author
    get :show, :author => 'Jamiroquai', :format => 'xml'
    assert_response :success

    assert_not_nil assigns(:songs)
    assert assigns(:songs).all? { |s| s.original_author == 'Jamiroquai' }
  end

  def test_search_by_country
    get :show, :country => 'Italy', :format => 'xml'

    assert_not_nil assigns(:tracks)
    assert assigns(:tracks).all? { |t| t.user.country == 'Italy' }

    assert_not_nil assigns(:songs)
    assert assigns(:songs).all? { |s| s.user.country == 'Italy' }
  end

end
