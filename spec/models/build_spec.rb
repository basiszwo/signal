require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Build do

  # should_belong_to :project
  # should_validate_presence_of :project, :output, :commit, :author, :comment
  # it_should_behave_like 'statusable'

  describe "on creation" do
    before :each do
      fail_on_command
      File.stub!(:open).and_return(mock(Object, :read => "lorem ipsum"))
      @project = Factory.create(:project, :branch => "staging")
      build_repo_for @project
    end

    it "should pull the repository from the project url and branch" do
      expect_for "cd #{@project.send :path} && git pull #{@project.url} #{@project.branch} > #{@project.send :log_path} 2>&1"
      Factory(:build, :project => @project)
    end

    it "should build the project unsetting RUBYOPT, RAILS_ENV, BUNDLE_GEMFILE and executing the project's build script" do
      expect_for "unset RUBYOPT && unset RAILS_ENV && unset BUNDLE_GEMFILE && cd #{@project.send :path} && ./#{@project.send :build_shell_script} #{@project.ruby_version} #{@project.rvm_gemset_name} >> #{@project.send :log_path} 2>&1"
      Factory(:build, :project => @project)
    end

    it "should save the log" do
      log = "Can't touch this!"
      File.stub!(:open).with(@project.send :log_path).and_return(mock(Object, :read => log))
      build = Factory(:build, :project => @project)
      build.output.should eql(log)
    end

    it "should determine if the build was a success or not" do
      fail_on_command
      build = Factory(:build, :project => @project)
      build.success.should be_false
    end

    it "should not deliver a fail notification email when build succeeds" do
      success_on_command
      build = Build.new :project => @project
      Notifier.should_not_receive(:fail_notification).with(build)
      build.save
    end

    it "should deliver an fail notification email if build fails" do
      fail_on_command
      build = Build.new :project => @project
      Notifier.fail_notification(build).should_receive(:deliver)
      build.save
    end

    it "should deliver a fix notification email if build succeeds and last build failed" do
      success_on_command
      Build.stub!(:last).and_return(mock(Build, :success => false))
      build = Build.new :project => @project
      Notifier.fix_notification(build).should_receive(:deliver)
      build.save
    end

    it "should not deliver a fix notification email if build succeeds and last build succeeded" do
      success_on_command
      Build.stub!(:last).and_return(mock(Build, :success => true))
      build = Build.new :project => @project
      Notifier.should_not_receive(:fix_notification).with(build)
      build.save
    end

    it "should not deliver a fix notification email if build failed and last build failed" do
      fail_on_command
      Build.stub!(:last).and_return(mock(Build, :success => false))
      build = Build.new :project => @project
      Notifier.should_not_receive(:deliver_fix_notification).with(build)
      build.save
    end

    it "should not deliver a fix notification email if build failed and last build succeeded" do
      fail_on_command
      Build.stub!(:last).and_return(mock(Build, :success => false))
      build = Build.new :project => @project
      Notifier.should_not_receive(:deliver_fix_notification).with(build)
      build.save
    end

    it "should save the author of the commit that forced the build" do
      build = Factory(:build, :project => @project)
      build.author.should eql(@author)
    end

    it "should save the hash of the commit that forced the build" do
      build = Factory(:build, :project => @project)
      build.commit.should eql(@commit)
    end

    it "should save the comment of the commit that forced the build" do
      build = Factory(:build, :project => @project)
      build.comment.should eql(@comment)
    end
  end
end
