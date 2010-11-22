class Deploy < ActiveRecord::Base
  include Status

  belongs_to :project
  validates_presence_of :project, :output

  before_validation :run_deploy ,:on => :create
  
  def run_deploy
    return nil if project.nil?
    self.success, self.output = project.run_deploy
  end
end
