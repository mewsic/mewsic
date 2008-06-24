require File.dirname(__FILE__) + '/../test_helper'

class AbuseMailerTest < ActionMailer::TestCase
  tests AbuseMailer
  def test_notification
    @expected.subject = 'AbuseMailer#notification'
    @expected.body    = read_fixture('notification')
    @expected.date    = Time.now

    assert_equal @expected.encoded, AbuseMailer.create_notification(@expected.date).encoded
  end

end
