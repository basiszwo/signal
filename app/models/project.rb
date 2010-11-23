class Project < ActiveRecord::Base
  BASE_PATH = "#{Rails.root}/public/projects"
  BUILDING = "building"
  
  scope :ordered_by_name, order('name')

  has_friendly_id :name, :use_slug => true, :approximate_ascii => true
  before_update :rename_directory

  validates_presence_of :name, :url, :email, :ruby_version, :rvm_gemset_name
  # validates_uniqueness_of :name, :case_sensitive => false

  has_many :builds, :dependent => :destroy
  has_many :deploys, :dependent => :destroy

  after_create :initialize_project
  after_destroy :remove_project_from_filesystem

  def initialize_project
    execute "cd #{BASE_PATH} && git clone --depth 1 #{url} #{name_to_filesystem}"
    run "git checkout -b #{branch} origin/#{branch} >" unless branch.eql? "master"
    execute "cp data/#{build_shell_script} #{path}/"
  end

  def remove_project_from_filesystem
    # running Kernel.system to make rspec pass
    Kernel.system "rm -rf #{path}"
  end
  
  def status
    building ? BUILDING : builds.last.try(:status)
  end

  def build
    update_attribute :building, true
    builds.create
    update_attribute :building, false
  end

  def deploy
    deploys.create
  end

  def last_builded_at
    builds.last.try(:created_at)
  end

  def has_file?(file)
    File.exists?("#{path}/#{file}") 
  end

  def activity
    building? ? 'Building' : 'Sleeping'
  end
  
  
  def name_to_filesystem
    name.downcase.gsub(/\s/, '_')
  end
  
  def name_was_to_filesystem
    name_was.downcase.gsub(/\s/, '_')
  end
  
  protected
  
    def build_shell_script
      "signal_build.sh"
    end

    def rename_directory
      execute "cd #{BASE_PATH} && mv #{name_was_to_filesystem} #{name_to_filesystem}" if self.name_changed?
    end

    def update_code
      run "git pull #{url} #{branch} >"
    end

    def last_commit
      Git.open(path).log.first
    end

    def run_build_command
      result = execute "unset RUBYOPT && unset RAILS_ENV && unset BUNDLE_GEMFILE && cd #{path} && ./signal_build.sh #{ruby_version} #{rvm_gemset_name} >> #{log_path} 2>&1"
    
      return result, (File.open(log_path).read rescue '')
    end

    def run_deploy
      return run("#{self.deploy_command} >"), File.open(log_path).read
    end

  
  private

    def path
      "#{BASE_PATH}/#{name_to_filesystem}"
    end

    def log_path
      "#{Rails.root}/tmp/#{name_to_filesystem}"
    end

    def run(cmd)
      execute "cd #{path} && #{cmd} #{log_path} 2>&1"
    end

    def execute(command)
      Rails.logger.info "Signal => #{command}"
      Kernel.system command
    end
end
