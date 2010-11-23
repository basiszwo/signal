
require 'rspec/mocks'
require 'rspec/mocks/extensions/object'

Before do
  Kernel.stub!(:system)
  repo = Git.open Rails.root
  Git.stub!(:open).and_return(repo)
  File.open(Rails.root + "/tmp/whatever", 'w') { |f| f.write "fqwfwefwejkiwegw" }
end
