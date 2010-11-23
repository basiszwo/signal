require "email_spec/helpers"
require "email_spec/matchers"
require 'fakefs'

FakeFS.activate!

def random_word
  Faker::Lorem.words(1).first
end

def build_author
  object = Git::Author.new ''
  object.stub!(:name).and_return(@author = Faker::Name.name)
  object
end

def build_commit
  object = mock(Object)
  object.stub!(:author).and_return(build_author)
  object.stub!(:message).and_return(@comment = random_word)
  object.stub!(:sha).and_return(@commit = random_word)
  object
end

def build_repo_for(project)
  @commits = [build_commit, build_commit].reverse
  Git.stub!(:open).with(project.send :path).and_return(mock(Object, :log => @commits))
end

def expect_for(command)
  Kernel.should_receive(:system).with command
end

def dont_accept(command)
  Kernel.should_not_receive(:system).with command
end

def on_command_return(result)
  Kernel.stub!(:system).and_return(result)
end

def fail_on_command
  on_command_return false
end

def success_on_command
  on_command_return true
end

def file_exists(file, opts = {})
  File.open(file, 'w') { |f| f.write(opts[:content] || '') }
end

def file_doesnt_exists(file)
  File.delete file
end

def create_project
  Factory.create(:project, :name => "signal", :url => "git@signal", :email => "signal@signal.com", :ruby_version => 'ruby-1.8.7', :rvm_gemset_name => 'signal_app')
  
  # returning Project.new :name => "signal", :url => "git@signal", :email => "signal@signal.com", :ruby_version => 'ruby-1.8.7', :rvm_gemset_name => 'signal_app' do |project|
  #   project.stub!(:execute)
  #   project.save!
  # end
end
