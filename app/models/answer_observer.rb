class AnswerObserver < ActiveRecord::Observer
  def after_create(answer)
    MyousicaMailer.deliver_new_answer_notification(answer)
  end
end
