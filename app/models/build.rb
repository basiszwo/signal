class Build < ActiveRecord::Base
  include Status

  belongs_to :project
  validates_presence_of :project, :output, :commit, :author, :comment
  
  scope :reverse_and_limited, lambda {|limit| { :limit => (limit || 10), :order => 'id DESC' } }
  
  before_validation :update_project_code, :on => :create
  after_validation :deliver_fix_notification, :on => :create
  after_create :deliver_fail_notification

  protected

    # TODO: refactor with move method
    def update_project_code
      return nil if project.nil?
      project.update_code
      self.success, self.output = project.run_build_command
      take_data_from project.last_commit
    end

    def deliver_fix_notification
      Notifier.deliver_fix_notification self if fix?
    end
    
    def deliver_fail_notification
      Notifier.deliver_fail_notification self unless success
    end


  private

    def take_data_from(commit)
      self.commit = commit.sha
      self.author = commit.author.name
      self.comment = commit.message
    end

    def fix?
      success and Build.last.try(:success) == false
    end

end