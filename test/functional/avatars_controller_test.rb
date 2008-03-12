require File.dirname(__FILE__) + '/../test_helper'

class Avatar < Picture
  belongs_to :user
  
  has_attachment :storage => :file_system,
    :path_prefix => 'test_uploaded_photos',
    :content_type => 'image/jpeg'
end

class AvatarsControllerTest < ActionController::TestCase

  include AuthenticatedTestHelper
  
  fixtures :users, :pictures
  
  def teardown
    FileUtils.rm_rf(File.join(RAILS_ROOT, 'test_uploaded_photos'))
  end
  
  def test_should_route_user_avatars
    options = {:controller => 'avatars', :action => 'new', :user_id => users(:quentin).id.to_s }
    assert_routing "/users/#{users(:quentin).id}/avatars/new", options
  end
  
  def test_new_should_redirect_unless_logged
    get :new, :user_id => users(:quentin).id
    assert_response :redirect
  end
  
  def test_new_should_success_if_logged
    login_as :quentin
    get :new, :user_id => users(:quentin).id
    assert_response :success
  end
  
  def test_should_redirect_if_user_not_found_or_not_activated
    get :new, :user_id => users(:aaron)
    assert_response :redirect
    get :new, :user_id => 99999999
    assert_response :redirect
  end    
  
  def test_create_should_redirect_unless_current_user_avatars
    login_as :user_10
    post :create, :user_id => users(:quentin)
    assert_not_nil assigns["user"]
    assert_nil assigns["avatars"]
    assert_response :redirect
  end
  
  def test_should_not_create_if_file_is_blank
    login_as :quentin
    assert_no_difference 'Avatar.count' do 
      post :create, :user_id => users(:quentin), :avatar  => {}
    end
  end  

  def test_should_create_and_destroy_previous        
    login_as :quentin
    assert_difference 'Avatar.count' do             
      post :create, :user_id => users(:quentin), :avatar => {
        :uploaded_data => uploaded_file(File.join(RAILS_ROOT, 'test/fixtures/files/test.jpg'), 'image/jpeg')
      }
      post :create, :user_id => users(:quentin), :avatar => {
        :uploaded_data => uploaded_file(File.join(RAILS_ROOT, 'test/fixtures/files/test.jpg'), 'image/jpeg')
      }      
    end
    assert_equal 1, users(:quentin).avatars.count
  end
  
  def test_should_not_create_if_not_current_user
    login_as :user_3
    quentin_avatars_count = users(:quentin).avatars.count
    user_3_avatars_count = users(:user_3).avatars.count
    assert_no_difference 'Photo.count' do 
      post :create, :user_id => users(:quentin),
        :avatar => {
          :uploaded_data => uploaded_file(File.join(RAILS_ROOT, 'test/fixtures/files/test.jpg'), 'image/jpeg')
        }
    end
    assert_equal quentin_avatars_count, users(:quentin).avatars.count
    assert_equal user_3_avatars_count, users(:user_3).avatars.count
  end
  
  def test_should_not_create_unless_logged_in
    assert_no_difference 'Avatar.count' do 
      post :create, :user_id => users(:quentin),
        :avatars => {
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
