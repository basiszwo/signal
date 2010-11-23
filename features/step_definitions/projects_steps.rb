# When /^I request '(.*)'$/ do |path|
#   visit path
# end

# When /^a new project should be created$/ do
#   Project.count.should == 1
# end

Then /^a new build should be created$/ do
  @build = @subject = Build.first
end

Then /^a new deploy should be created$/ do
  @deploy = @subject = Deploy.first
end

Then /^I should see the author of the build$/ do
  page.should have_xpath('//*', :text => @build.author)
end

Then /^I should see the name of the project$/ do
  project = Project.last
  page.should have_xpath('//title', :text => project.name)
end

Then /^I should see the output of the deploy$/ do
  page.should have_xpath('//*', :text => @deploy.output)
end

Then /^I should get a XML document$/ do
  page.body.should_not be_empty
end

Then /^I should receive a link for the feed of all projects$/ do
  page.should have_xpath('//link[@type="application/rss+xml"]')
end

Then /^I should receive a link for the feed of the project$/ do
  project = Project.last
  page.should have_xpath("//link[@type='application/rss+xml'][@href='/projects/#{project.slug.name}.rss'][@title='#{project.name}']")
end
