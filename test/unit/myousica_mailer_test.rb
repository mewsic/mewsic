require File.dirname(__FILE__) + '/../test_helper'

class MyousicaMailerTest < ActionMailer::TestCase
  tests MyousicaMailer
  def test_help
    @expected.subject = 'MyousicaMailer#help'
    @expected.body    = read_fixture('help')
    @expected.date    = Time.now

    assert_equal @expected.encoded, MyousicaMailer.create_help(@expected.date).encoded
  end

end
