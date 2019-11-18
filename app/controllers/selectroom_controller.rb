class SelectroomController < ApplicationController
  before_action :authenticate_user!
  
  def index
    logger.debug("selectroom indexに入りました")
    logger.debug(params)
    
    logger.debug(current_user.name)

    
  end
end
