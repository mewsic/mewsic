module AnswersHelper
  def current_user_answer_page?
    @answer.user == current_user
  end
end
