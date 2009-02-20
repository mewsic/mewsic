require File.dirname(__FILE__) + '/../test_helper'
require 'image_science'

class Avatar < Picture
  belongs_to :user
  
  has_attachment :storage => :file_system,
    :path_prefix => 'test_uploaded_photos',
    :content_type => 'image/jpeg'
end

class AvatarsControllerTest < ActionController::TestCase

  include AuthenticatedTestHelper
  
  fixtures :users, :pictures
  
  def setup
    FileUtils.mkdir_p(File.join(RAILS_ROOT, 'test_uploaded_photos'))
  end

  def teardown
    super
    FileUtils.rm_rf(File.join(RAILS_ROOT, 'test_uploaded_photos'))
  end
  
  def test_should_route_user_avatars
    user_id = users(:quentin).id
    options = {:controller => 'avatars', :action => 'update',
               :format => 'js', :user_id => user_id.to_s}
    path = "/users/#{user_id}/avatar.js"

    assert_generates path, options
    assert_recognizes options, { :path => path, :method => 'put' }
  end
  
  def test_update_should_redirect_unless_logged
    put :update, :user_id => users(:quentin).id, :format => 'js'
    assert_response 406
  end
  
  def test_update_should_success_if_logged
    login_as :quentin
    put :update, :user_id => users(:quentin).id, :format => 'js',
      :avatar => {
        :uploaded_data => uploaded_file(File.join(RAILS_ROOT, 'test/fixtures/files/test.jpg'), 'image/jpeg')
      }
    assert_response :success
  end
  
  def test_should_redirect_if_user_not_found_or_not_activated
    put :update, :user_id => users(:aaron), :format => 'js'
    assert_response 406
    put :update, :user_id => users(:aaron), :format => 'html'
    assert_response :redirect

    put :update, :user_id => 99999999, :format => 'js'
    assert_response 406
    put :update, :user_id => 99999999, :format => 'html'
    assert_response :redirect
  end    
  
  def test_update_should_redirect_unless_current_user_avatars
    login_as :user_10
    put :update, :user_id => users(:quentin), :format => 'js'
    assert_not_nil assigns["pictureable"]
    assert_nil assigns["avatar"]
    assert_response :redirect

    put :update, :user_id => users(:quentin), :format => 'html'
    assert_response :redirect
  end
  
  def test_should_not_create_if_file_is_blank
    login_as :quentin
    assert_no_difference 'Avatar.count' do 
      put :update, :user_id => users(:quentin), :avatar  => {}, :format => 'js'
    end
    assert_response :bad_request
  end  

  def test_should_create_and_destroy_previous        
    login_as :user_300
    assert_difference 'Avatar.count' do             
      put :update, :user_id => users(:user_300), :avatar => {
        :uploaded_data => uploaded_file(File.join(RAILS_ROOT, 'test/fixtures/files/test.jpg'), 'image/jpeg')
      }, :format => 'js'
      put :update, :user_id => users(:user_300), :avatar => {
        :uploaded_data => uploaded_file(File.join(RAILS_ROOT, 'test/fixtures/files/test.jpg'), 'image/jpeg')
      }, :format => 'js'
    end
    assert_not_nil users(:user_300).avatar
    assert_response :success
  end
  
  def test_should_not_create_if_not_current_user
    login_as :user_3
    quentin_avatar_nil = users(:quentin).avatar.nil?
    user_3_avatar_nil = users(:user_3).avatar.nil?
    assert_no_difference 'Avatar.count' do 
      put :update, :user_id => users(:quentin),
        :avatar => {
          :uploaded_data => uploaded_file(File.join(RAILS_ROOT, 'test/fixtures/files/test.jpg'), 'image/jpeg')
        }, :format => 'js'
    end
    assert_response :redirect
    assert_equal quentin_avatar_nil, users(:quentin).avatar.nil?
    assert_equal user_3_avatar_nil, users(:user_3).avatar.nil?
  end
  
  def test_should_not_create_unless_logged_in
    assert_no_difference 'Avatar.count' do 
      put :update, :user_id => users(:quentin),
        :avatar => {
          :uploaded_data => uploaded_file(File.join(RAILS_ROOT, 'test/fixtures/files/test.jpg'), 'image/jpeg')
        }, :format => 'js'
    end
    assert_response 406
  end    

  def test_should_crop_and_resize_avatar
    login_as :quentin
    put :update, :user_id => users(:quentin),
      :avatar => {
        :uploaded_data => uploaded_file(File.join(RAILS_ROOT, 'test/fixtures/files/test.jpg'), 'image/jpeg')
      }, :format => 'js'
    assert_response :success

    avatar = users(:quentin).avatar
    Avatar.attachment_options[:thumbnails].each do |key, size|
      next unless size.is_a? Fixnum # Check only fixed-size images

      ImageScience.with_image(avatar.full_filename(key)) do |img|
        assert_equal img.width, img.height
        assert_equal img.width, size
      end
    end
  end

	def test_should_validate_content_type
    login_as :user_250
    assert_no_difference 'Avatar.count' do 
      put :update, :user_id => users(:user_250),
        :avatar => {
          :uploaded_data => uploaded_file(File.join(RAILS_ROOT, 'test/fixtures/mlabs.yml'), 'text/yaml')
        }, :format => 'js'
    end
    assert_response :success

    assert_nil users(:user_250).avatar
	end

	def test_should_keep_current_avatar_in_case_of_failure
    login_as :user_240
    assert_difference 'Avatar.count' do 
      put :update, :user_id => users(:user_240),
        :avatar => {
          :uploaded_data => uploaded_file(File.join(RAILS_ROOT, 'test/fixtures/files/test.jpg'), 'image/jpeg')
        }, :format => 'js'
    end

    assert_response :success
    assert_not_nil users(:user_240).avatar

    assert_no_difference 'Avatar.count' do 
      put :update, :user_id => users(:user_240),
        :avatar => {
          :uploaded_data => uploaded_file(File.join(RAILS_ROOT, 'test/fixtures/mlabs.yml'), 'text/yaml')
        }, :format => 'js'
    end

    assert_response :success
    assert_not_nil users(:user_240).avatar
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
