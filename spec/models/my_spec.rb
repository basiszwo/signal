
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Project" do
  before(:each) do
    # @project = Factory.build(:project, :branch => 'staging' )
    @project = Factory(:project, :branch => 'staging' )
  end
  
  it "should be a dumb test to show usage" do
    @project.branch.should == "staging"
  end
end