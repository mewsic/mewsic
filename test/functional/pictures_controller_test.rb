require File.dirname(__FILE__) + '/../test_helper'

class Picture < ActiveRecord::Base
  belongs_to :user
  
  has_attachment :storage => :file_system,
    :path_prefix => 'test_uploaded_pictures',
    :content_type => 'image/jpeg'
end


class PicturesControllerTest < ActionController::TestCase

  include AuthenticatedTestHelper
  
  fixtures :users, :pictures
  
  def teardown
    FileUtils.rm_rf(File.join(RAILS_ROOT, 'test_uploaded_pictures'))
  end
  
  def test_should_route_user_pictures
    options = {:controller => 'pictures', :action => 'index', :user_id => users(:quentin).id.to_s }
    assert_routing "/users/#{users(:quentin).id}/pictures", options
  end
  
  def test_should_redirect_if_user_not_found_or_not_activated
    get :index, :user_id => users(:aaron)
    assert_response :redirect
    get :index, :user_id => 99999999
    assert_response :redirect
  end
  
  def test_should_show_user_pictures
    get :index, :user_id => users(:quentin)
    assert_not_nil assigns["user"]
    assert_not_nil assigns["pictures"]
    assert_response :success
  end
  
  def test_create_should_redirect_unless_current_user_pictures
    post :create, :user_id => users(:quentin)
    assert_not_nil assigns["user"]
    assert_nil assigns["pictures"]
    assert_response :redirect
  end
  
  def test_destroy_should_redirect_unless_current_user_pictures
    assert_no_difference 'Picture.count' do
      post :destroy, :user_id => users(:quentin), :id => pictures(:second_pictures_for_quentin)
      assert_not_nil assigns["user"]
      assert_nil assigns["pictures"]
      assert_response :redirect
    end
  end
  
  def test_should_destroy
    login_as :quentin
    assert_difference 'Picture.count', -1 do
      post :destroy, :user_id => users(:quentin), :id => pictures(:second_pictures_for_quentin)
      assert_not_nil assigns["user"]
      assert_response :redirect
    end
  end
  
  def test_should_not_destroy_if_picture_not_owned_by_current_user
    login_as :quentin
    assert_no_difference 'Picture.count' do
      post :destroy, :user_id => users(:quentin), :id => pictures(:first_pictures_for_users_1)
      assert_not_nil assigns["user"]
      assert_response :redirect
    end
  end  

  def test_should_create
    login_as :quentin
    quentin_pictures_count = users(:quentin).pictures.count
    assert_difference 'Picture.count' do 
      post :create, :user_id => users(:quentin),
        :picture => {
          :uploaded_data => uploaded_file(File.join(RAILS_ROOT, 'test/fixtures/files/test.jpg'), 'image/jpeg')
        }
    end
    assert_equal quentin_pictures_count + 1, users(:quentin).pictures.count
  end
  
  def test_should_not_create_if_not_current_user
    login_as :user_3
    quentin_pictures_count = users(:quentin).pictures.count
    user_3_pictures_count = users(:user_3).pictures.count
    assert_no_difference 'Picture.count' do 
      post :create, :user_id => users(:quentin),
        :picture => {
          :uploaded_data => uploaded_file(File.join(RAILS_ROOT, 'test/fixtures/files/test.jpg'), 'image/jpeg')
        }
    end
    assert_equal quentin_pictures_count, users(:quentin).pictures.count
    assert_equal user_3_pictures_count, users(:user_3).pictures.count
  end
  
  def test_should_not_create_unless_logged_in
    assert_no_difference 'Picture.count' do 
      post :create, :user_id => users(:quentin),
        :picture => {
          :uploaded_data => uploaded_file(File.join(RAILS_ROOT, 'test/fixtures/files/test.jpg'), 'image/jpeg')
        }
    end
  end    

private

  def uploaded_file(path, content_type = "image/jpeg", filename = nil)
    filename ||= File.basename(path)
    t = Tempfile.new(filename)
    FileUtils.copy_file(path, t.path)
    (class << t; self; end;).class_eval do
      alias local_path path
      define_method(:original_filename) { filename }
      define_method(:content_type) { content_type }
    end
    return t
  end
  
end
