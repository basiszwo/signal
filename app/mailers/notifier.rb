class Notifier < ActionMailer::Base
  helper :projects
  helper :builds

  default :from => "signal@#{MAILER['domain']}"
  
  def fail_notification(build)
    deliver build, "failed"
  end

  def fix_notification(build)
    deliver build, "fixed"
  end

  private

    def deliver(build, status)      
      @build = build
      @project = build.project
      
      mail(:to => @project.email,
           :subject => "[Signal] #{@project.name} #{status}" )
    end
end
