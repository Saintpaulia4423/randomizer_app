module ApplicationHelper
  def current_set
    RandomSet.find(params[:random_set_id]) 
  end
end
