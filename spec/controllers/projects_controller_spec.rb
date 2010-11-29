require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProjectsController do  
  # should_behave_like_resource :formats => [:html, :xml, :rss]

  describe "responding to build" do
    it "should build a project in the background" do
      Project.stub!(:find).with(project_id = "10").and_return(project = mock(Project))
      project.should_receive(:send_later).with(:build)
      get :build, :project_id => project_id
    end
  end

  describe "responding to status" do
    render_views
    
    before :each do
      Project.stub!(:all).and_return(@projects = [Project.new])
    end
    # 
    # it "with html format should render projects template" do
    #   get :status
    #   render
    #   response.should render_template(:partial => "shared/_projects")
    # end
    # 
    # it "with xml format should render status.xml" do
    #   get :status, :format => 'xml'
    #   render
    #   response.should render_template("status.xml")
    # end

    it "should assign all the projects to @projects" do
      get :status
      assigns(:projects).should eq(@projects)
    end
  end
end
