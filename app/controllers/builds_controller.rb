class BuildsController < InheritedResources::Base
  
  belongs_to :project
  
  protected
  
    def collection
      @builds ||= end_of_association_chain.reverse_and_limited(5)
    end
  
end
