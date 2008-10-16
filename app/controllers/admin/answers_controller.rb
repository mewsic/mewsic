class Admin::AnswersController < Admin::AdminController #:nodoc:
  def index
    @answers = Answer.find(:all, :order => 'id DESC')
  end
  
  def show
    @answer = Answer.find(params[:id])
  end

  def update
    @answer = Answer.find(params[:id])
    @answer.update_attributes! params[:answer]
    render :action => 'show'
  end

  def destroy
    Answer.find(params[:id]).destroy
    update_after_destroy
  end

end
