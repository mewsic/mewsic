class Admin::AnswersController < Admin::AdminController
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
    render(:update) { |page| page.hide 'editing' }
  end

end
