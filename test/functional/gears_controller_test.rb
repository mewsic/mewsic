require File.dirname(__FILE__) + '/../test_helper'

class GearsControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper

  fixtures :users, :gears, :instruments

  def test_create_should_require_login
    post :create, :user_id => users(:quentin).id
    assert_redirected_to :login
  end

  def test_create_should_check_current_user
    login_as :quentin
    post :create, :user_id => users(:john).id
    assert_response :forbidden
  end

  def test_create_should_check_required_parameters
    login_as :quentin
    post :create, :user_id => users(:quentin).id
    assert_response :bad_request
  end

  def test_create_should_trigger_validations
    login_as :quentin

    quentin = users(:quentin)
    guitar = gears(:quentin_guitar)
    instrument = guitar.instrument

    post :create, :user_id => quentin.id, :gear => {
      guitar.id => {:model => '', :brand => '', :instrument_id => instrument.id}
    }

    assert_response :success # XXX FIXME SHOULD RETURN ERROR INSTEAD!

    assert_not_equal '', guitar.reload.model
    assert_not_equal '', guitar.reload.brand
  end

  def test_create_should_create_and_update_existing
    login_as :quentin

    quentin = users(:quentin)
    guitar = gears(:quentin_guitar)
    instrument = guitar.instrument

    post :create, :user_id => quentin.id,
      :gear => {guitar.id => {:model => 'sux', :brand => 'prot', :instrument_id => instrument.id}},
      :new_gear => {rand(2**16) => {:model => 'tapioca', :brand => 'antani', :instrument_id => instruments(:double_bass).id}}

    assert_response :success

    guitar.reload
    assert_equal 'sux', guitar.model
    assert_equal 'prot', guitar.brand
    assert_equal instrument, guitar.instrument

    quentin.reload
    assert_equal 3, quentin.gears.count

    new_gear = quentin.gears.to_a.last
    assert_equal 'tapioca', new_gear.model
    assert_equal 'antani', new_gear.brand
    assert_equal instruments(:double_bass), new_gear.instrument
  end
end
