require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < ActiveSupport::TestCase
  fixtures :comments, :users, :answers, :tracks, :songs, :mbands

  def test_counter_cache
    user = users(:user_4)
    answer = answers(:user_10_asks_about_soccer)
    assert_equal 0, answer.comments_count
    assert_equal 0, user.writings_count

    assert_commentable answer, :by => :user_4

    assert_equal 1, answer.reload.comments_count
    assert_equal 1, user.reload.writings_count
  end

  def test_associated_models
    assert_commentable songs(:let_it_be)
    assert_commentable tracks(:sax_for_let_it_be)
    assert_commentable answers(:quentin_asks_about_magic)
    assert_commentable users(:john)
    assert_commentable mbands(:scapokkier)
  end

  def test_that_user_cannot_rate_own_comments
    deny comments(:john_replies_to_quentins_magic_question).rateable_by?(users(:john))
  end
end
