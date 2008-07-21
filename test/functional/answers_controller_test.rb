require File.dirname(__FILE__) + '/../test_helper'

class AnswersControllerTest < ActionController::TestCase
  
  include AuthenticatedTestHelper
  
  fixtures :users, :answers
  
  def test_sould_show_answers
    get :index
    assert_response :success

    assert assigns(:open_answers)
    assert assigns(:top_answers)
    assert assigns(:top_answers_count)
    assert assigns(:newest_answers)
    assert assigns(:newest_answers_count)
    assert assigns(:top_contributors)
  end

  def test_should_show_answers_on_xhr
    xhr :get, :index, :user_id => users(:quentin).id
    assert_response :success

    assert assigns(:user)
    assert_equal users(:quentin).id, assigns(:user).id

    assert assigns(:answers)
    assert users(:quentin).id, assigns(:answers).map(&:user_id).uniq.first
  end

  def test_should_show_open_answers
    get :open
    assert_response :success

    assert assigns(:open_answers)
    assert assigns(:open_answers).all? {|a| !a.closed? }

    assert assigns(:top_contributors)
  end

  def test_should_show
    answer = answers(:user_10_asks_about_girls)
    get :show, :id => answer.id
    assert_response :success

    assert assigns(:answer)
    assert_equal answer.id, assigns(:answer).id

    assert assigns(:similar_answers)

    assert assigns(:other_answers_by_author)
    assert assigns(:other_answers_by_author).map(&:user_id).all? { |id| id == answer.user_id }
  end

  def test_should_fetch_siblings
    answer = answers(:user_10_asks_about_girls)

    xhr :get, :siblings, :id => answer.id, :page => 1
    assert_response :success

    assert assigns(:answer)
    assert_equal answer.id, assigns(:answer).id

    assert assigns(:other_answers_by_author)
    assert assigns(:other_answers_by_author).map(&:user_id).all? { |id| id == answer.user_id }
  end

  def test_should_fetch_top
    %w( open top newest ).each do |type|
      xhr :get, :top, :type => type, :page => 1
      assert_response :success
      assert_template '_index_list'
    end
  end
  
  def test_should_not_fetch_top
    xhr :get, :top, :type => 'antani'
    assert_response :bad_request
  end

  def test_create_should_redirect_unless_logged_in
    post :create
    assert_response :redirect
  end
  
  def test_create_should_validate_presence_of_body
    login_as :quentin
    assert_no_difference 'Answer.count' do
      post :create, :answer => {}
      assert_response :success
    end
  end
  
  def test_owner_should_update
    login_as :quentin
    post :update, :id => answers(:quentin_asks_about_magic).id, :answer => {:body => 'Hello world'}
    assert_not_nil flash[:notice]
    assert_response :redirect    
    assert_equal 'Hello world', answers(:quentin_asks_about_magic).reload.body
  end

  def test_should_validate_update
    login_as :quentin

    original_body = answers(:quentin_asks_about_magic).body
    post :update, :id => answers(:quentin_asks_about_magic).id, :answer => {:body => nil}

    assert_response :redirect
    assert_not_nil flash[:error]
    assert_equal original_body, answers(:quentin_asks_about_magic).reload.body
  end
  
  def test_owner_should_not_update_if_not_answer_owner
    login_as :user_11
    post :update, :id => answers(:quentin_asks_about_magic).id, :answer => {:body => 'Hello world'}
    assert_not_nil flash[:alert]
    assert_response :redirect    
    assert_equal 'Come si gioca a Magic The Gathering', answers(:quentin_asks_about_magic).reload.body
  end
  
  def test_owner_should_not_update_if_older_than_10_minutes
    answers(:quentin_asks_about_magic).update_attribute(:created_at, 20.minutes.ago)
    login_as :quentin
    post :update, :id => answers(:quentin_asks_about_magic).id, :answer => {:body => 'Hello world'}
    assert_not_nil flash[:alert]
    assert_response :redirect    
    assert_equal 'Come si gioca a Magic The Gathering', answers(:quentin_asks_about_magic).reload.body
  end    
  
  def test_should_create
    login_as :quentin
    quentin_answers_count = users(:quentin).answers.count
    assert_difference 'Answer.count' do
      post :create, :answer => { :body => "Waht's you name"}
      assert_response :redirect
    end
    assert_equal quentin_answers_count + 1, users(:quentin).answers.count
  end
  
  def test_should_not_rate
    login_as :quentin

    answer = answers(:quentin_asks_about_magic)
    post :rate, :id => answer.id, :rate => 2
    assert_response :bad_request
    assert_equal answer.rating_count, answer.reload.rating_count
  end

  def test_should_rate
    login_as :quentin

    answer = answers(:user_10_asks_about_soccer)
    post :rate, :id => answer.id, :rate => 2
    assert_response :success
    assert_equal 1, answer.reload.rating_count
  end

  def test_should_search
    get :search, :q => 'soccer'
    assert_response :success

    assert assigns(:answers)
    assert_equal 1, assigns(:answers).size
    assert_equal answers(:user_10_asks_about_soccer).id, assigns(:answers).first.id
    assert_template 'search'

    xhr :get, :search, :q => 'soccer'
    assert_response :success
    assert_template '_search_list'
  end

  def test_should_not_search
    get :search, :q => '', :format => 'html'
    assert_redirected_to answers_path

    get :search, :q => '%_%', :format => 'xml'
    assert_response :bad_request
  end

end
