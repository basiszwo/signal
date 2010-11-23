require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Project do
  
  # should_validate_presence_of :name, :url, :email, :ruby_version, :rvm_gemset_name
  # # should_validate_uniqueness_of :name
  # 
  # should_have_many :builds
  # should_have_many :deploys

  it "should have public/projects as the projects base path" do
    Project::BASE_PATH.should eql("#{Rails.root}/public/projects")
  end
  
  
  describe "on creation" do
    before :each do
      success_on_command
      @project = Factory.build(:project, :name => "Social App", :url => "git://social", :email => "fake@mouseoverstudio.com", :ruby_version => 'ruby-1.8.7', :rvm_gemset_name => 'social_app')
      # @project = Project.new :name => "Social App", :url => "git://social", :email => "fake@mouseoverstudio.com", :ruby_version => 'ruby-1.8.7', :rvm_gemset_name => 'social_app'
    end

    it "should create the correct project name for the filesystem" do
      @project.name_to_filesystem.should eql("social_app")
    end

    it "should clone a repository without the history" do
      expect_for "cd #{Project::BASE_PATH} && git clone --depth 1 #{@project.url} #{@project.name_to_filesystem}"
      @project.save
    end

    it "should checkout the configured branch if different from master" do
      @project.branch = branch = "integration"
      expect_for "cd #{@project.send :path} && git checkout -b #{branch} origin/#{branch} > #{@project.send :log_path} 2>&1"
      @project.save
    end

    it "should dont checkout the configured branch if it's master" do
      branch = @project.branch
      dont_accept "cd #{@project.send :path} && git checkout -b #{branch} origin/#{branch} > #{@project.send :log_path} 2>&1"
      @project.save
    end
    
    it "should copy the signal build shell script" do
      expect_for "cp data/#{@project.send :build_shell_script} #{@project.send :path}/"
      @project.save
    end
  end

  describe "on #build" do
    let(:project) { create_project }

    it "should create a new build" do
      project.builds.should_receive(:create)
      project.build
    end

    it "should set the project as building while building" do
      project.builds.should_receive(:create) do
        Project.last.should be_building
      end
      project.build
    end

    it "should set the project as not building after build" do
      project.builds.stub!(:create)
      project.build
      project.should_not be_building
    end
        
  end

  describe "on #activity" do
    it "should return Sleeping when not being build" do
      Project.new(:building => false).activity.should eql('Sleeping')
    end

    it "should return Building when being build" do
      Project.new(:building => true).activity.should eql('Building')
    end
  end
  
  describe "on #destroy" do
    let(:project) { create_project }
    
    it "should delete the project from the filesystem" do
      path = project.send :path
      
      expect_for "rm -rf #{path}"
      project.destroy
    end
  end

  describe "when returing the status" do
    before :each do
      @project = Project.new :builds => [@build = Build.new]
    end

    it "should return #{Build::SUCCESS} when the last build was successful" do
      @build.success = true
      @project.status.should eql(Build::SUCCESS)
    end

    it "should return #{Build::FAIL} when the last build was not successful" do
      @build.success = false
      @project.status.should eql(Build::FAIL)
    end

    it "should return #{Project::BUILDING} when the build is running" do
      @project.building = true
      @project.status.should eql(Project::BUILDING)
    end

    it "should return nil when there are no builds" do
      @project.builds = []
      @project.status.should be_nil
    end
  end

  it "should return when was the last build" do
    date = Time.now
    Project.new(:builds => [Build.new :created_at => date]).last_builded_at.should eql(date)
  end

  describe "on update" do
    before :each do
      success_on_command
      @project = Project.create! :name => "Project 1",:url => "git://social", :email => "fake@mouseoverstudio.com", :ruby_version => 'ruby-1.8.7', :rvm_gemset_name => 'project_1'
    end

    it "should rename the directory when the name changes" do
      expect_for "cd #{Project::BASE_PATH} && mv project_1 project_2"
      @project.update_attributes :name => "Project 2"
    end

    it "should not rename the directory when the name doesn't change" do
      dont_accept "cd #{Project::BASE_PATH} && mv project1 project1"
      @project.update_attributes :email => "fak2@faker.com"
    end
  end

  it "should return nil as last build date when no builds exists" do
    Project.new.last_builded_at.should be_nil
  end

  it "should have name as a friendly_id" do
    name = "rails"
    Project.new(:name => name).friendly_id.should eql(name)
  end

  it "should deploy the project creating a new deploy" do
    project = Project.new
    project.deploys.should_receive(:create)
    project.deploy
  end

  it "should use master as the default branch" do
    subject.branch.should eql("master")
  end

  describe "on has_file?" do
    it "should return true if the project has the file path" do
      subject.name = "Signal One"
      
      file_exists(subject.send(:path) + '/doc/specs.html')
      subject.has_file?("doc/specs.html").should be_true
    end

    it "should return false if the project doesnt has the file path" do
      subject.name = "Signal One"
      
      file_doesnt_exists(subject.send(:path) + '/doc/specs.html')
      subject.has_file?("doc/specs.html").should be_false
    end
  end
end
