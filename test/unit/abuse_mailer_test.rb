require File.dirname(__FILE__) + '/../test_helper'

class AbuseMailerTest < ActionMailer::TestCase
  tests AbuseMailer
  fixtures :answers, :users

  def setup
    super
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  def test_notification
    abuseable = answers(:quentin_asks_about_magic)
    abuse = Abuse.new :abuseable_id => abuseable.id, :abuseable_type => abuseable.class.name
    sender = users(:quentin)

    AbuseMailer.deliver_notification(abuseable, abuse, sender)
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

end
