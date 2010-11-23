class ProjectsController < InheritedResources::Base
  respond_to :html, :xml, :rss
  
  def build
    Project.find(params[:project_id]).send_later :build
    render :nothing => true
  end

  def status
    @projects = Project.all
    
    # respond_to do |format|
    #   format.html #{ render :layout => false, :partial => "shared/projects" }
    #   format.xml
    # end
    
  end
  
  
  protected
    def collection
      @projects ||= end_of_association_chain.ordered_by_name
    end
  
end
