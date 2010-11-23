Factory.define :project do |f|
  f.sequence(:name) {|n| "Test Project #{n}" }
  
  f.url 'git://fake'
  f.email 'my@email.com'
  f.branch 'master'
  f.deploy_command 'cap deploy'
  f.building 0
  f.ruby_version 'ruby-1.8.7'
  f.rvm_gemset_name 'testproject'
end
    