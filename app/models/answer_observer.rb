# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
# Copyright:: (C) 2008 Adelao Group
#
# This observer sends out notifications to admins when a new answer is being created
# (see +MyousicaMailer#new_answer_notification+).
#
class AnswerObserver < ActiveRecord::Observer
  def after_create(answer)
    MyousicaMailer.deliver_new_answer_notification(answer)
  end
end
