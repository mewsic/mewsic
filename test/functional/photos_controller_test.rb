require File.dirname(__FILE__) + '/../test_helper'

class Photo < Picture
  belongs_to :user
  
  has_attachment :storage => :file_system,
    :path_prefix => 'test_uploaded_photos',
    :content_type => 'image/jpeg'
end

class PhotosControllerTest < ActionController::TestCase

  include AuthenticatedTestHelper
  
  fixtures :users, :pictures
  
  def teardown
    FileUtils.rm_rf(File.join(RAILS_ROOT, 'test_uploaded_photos'))
  end
  
  def test_should_route_user_photos
    options = {:controller => 'photos', :action => 'index', :user_id => users(:quentin).id.to_s }
    assert_routing "/users/#{users(:quentin).id}/photos", options
  end
  
  def test_index_should_redirect_unless_logged
    get :index, :user_id => users(:quentin).id
    assert_response :redirect
  end
  
  def test_index_should_success_if_logged
    login_as :quentin
    get :new, :user_id => users(:quentin).id
    assert_response :success
  end
  
  def test_should_redirect_if_user_not_found_or_not_activated
    get :index, :user_id => users(:aaron)
    assert_response :redirect
    get :index, :user_id => 99999999
    assert_response :redirect
  end    
  
  def test_create_should_redirect_unless_current_user_photos
    login_as :user_10
    post :create, :user_id => users(:quentin)
    assert_not_nil assigns["user"]
    assert_nil assigns["photos"]
    assert_response :redirect
  end
  
  def test_destroy_should_redirect_unless_current_user_photos
    login_as :user_10
    assert_no_difference 'Photo.count' do
      post :destroy, :user_id => users(:quentin), :id => pictures(:second_photo_for_quentin)
      assert_not_nil assigns["user"]
      assert_nil assigns["photos"]
      assert_response :redirect
    end
  end
  
  def test_should_destroy
    login_as :quentin
    assert_difference 'Photo.count', -1 do
      post :destroy, :user_id => users(:quentin), :id => pictures(:second_photo_for_quentin)
      assert_not_nil assigns["user"]
      assert_response :redirect
    end
  end
  
  def test_should_not_destroy_if_photo_not_owned_by_current_user
    login_as :quentin
    assert_no_difference 'Photo.count' do
      begin
        post :destroy, :user_id => users(:quentin), :id => pictures(:first_photo_for_users_1)
      rescue Exception => e
        assert e.kind_of?(ActiveRecord::RecordNotFound)
      end
    end
  end
  
  def test_should_not_create_if_file_is_blank
    login_as :quentin
    assert_no_difference 'Photo.count' do 
      post :create, :user_id => users(:quentin),
        :photo => {}
    end
  end  

  def test_should_create
    login_as :quentin
    quentin_photos_count = users(:quentin).photos.count
    assert_difference 'Photo.count' do 
      post :create, :user_id => users(:quentin),
        :photo => {
          :uploaded_data => uploaded_file(File.join(RAILS_ROOT, 'test/fixtures/files/test.jpg'), 'image/jpeg')
        }
    end
    assert_equal quentin_photos_count + 1, users(:quentin).photos.count
  end
  
  def test_should_not_create_if_not_current_user
    login_as :user_3
    quentin_photos_count = users(:quentin).photos.count
    user_3_photos_count = users(:user_3).photos.count
    assert_no_difference 'Photo.count' do 
      post :create, :user_id => users(:quentin),
        :photo => {
          :uploaded_data => uploaded_file(File.join(RAILS_ROOT, 'test/fixtures/files/test.jpg'), 'image/jpeg')
        }
    end
    assert_equal quentin_photos_count, users(:quentin).photos.count
    assert_equal user_3_photos_count, users(:user_3).photos.count
  end
  
  def test_should_not_create_unless_logged_in
    assert_no_difference 'Photo.count' do 
      post :create, :user_id => users(:quentin),
        :photo => {
          :uploaded_data => uploaded_file(File.join(RAILS_ROOT, 'test/fixtures/files/test.jpg'), 'image/jpeg')
        }
    end
  end    

  def test_should_crop_and_resize_photo
    quentin_photos_count = users(:quentin).photos.count

    login_as :quentin
    assert_difference 'Photo.count', 2 do
      post :create, :user_id => users(:quentin),
        :photo => {
          :uploaded_data => uploaded_file(File.join(RAILS_ROOT, 'test/fixtures/files/test.jpg'), 'image/jpeg')
        }
      post :create, :user_id => users(:quentin),
        :photo => {
          :uploaded_data => uploaded_file(File.join(RAILS_ROOT, 'test/fixtures/files/photo_user_test.jpg'), 'image/jpeg')
        }
    end
    assert_equal quentin_photos_count + 2, users(:quentin).photos.count

    users(:quentin).photos.each do |photo|
      Avatar.attachment_options[:thumbnails].each do |key, size|
        next unless size.is_a? Fixnum # Check only fixed-size images

        ImageScience.with_image(photo.full_filename(key)) do |img|
          assert_equal img.width, img.height
          assert_equal img.width, size
        end
      end
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
