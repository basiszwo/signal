require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Notifier do

  include EmailSpec::Helpers
  include EmailSpec::Matchers

  before :all do
    @address = "all@mouseoverstudio.com"
    @name = "rails"
    @project = Factory.build(:project, :email => @address, :name => @name)
    @build = Build.new(:project => @project, :output => '')
  end

  describe "delivering fail notification" do
    before :all do
      @email = Notifier.fail_notification(@build).deliver
    end

    it "should deliver to project email" do
       @email.should deliver_to(@address)
    end

    it "should set '[Signal] PROJECT_NAME failed' as the subject" do
      @email.should have_subject("[Signal] #{@name} failed")
    end

    it "should deliver from signal@MAILER_DOMAIN" do
      @email.should deliver_from("signal@#{MAILER['domain']}")
    end

    it "should deliver as HTML with chartset UTF-8" do
      @email.header['content-type'].to_s.should eql("text/html; charset=utf-8")
    end
  end

  describe "delivering fix notification" do
    before :all do
      @email = Notifier.fix_notification(@build).deliver
    end

    it "should deliver to project email" do
       @email.should deliver_to(@address)
    end

    it "should set '[Signal] PROJECT_NAME fixed' as the subject" do
      @email.should have_subject("[Signal] #{@name} fixed")
    end

    it "should deliver from signal@MAILER_DOMAIN" do
      @email.should deliver_from("signal@#{MAILER['domain']}")
    end
  end
end
