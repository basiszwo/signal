class AddRubyVersionAndRvmGemsetNameToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :ruby_version, :string
    add_column :projects, :rvm_gemset_name, :string
    
    remove_column :projects, :build_command
  end

  def self.down
    add_column :projects, :build_command, :string
    
    remove_column :projects, :ruby_version
    remove_column :projects, :rvm_gemset_name
  end
end
