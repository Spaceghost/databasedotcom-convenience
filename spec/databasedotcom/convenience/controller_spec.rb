require 'spec_helper'

def set_env env, *frameworks
  if frameworks.empty? || frameworks.include?(:all)
    %w{rails rack app}.each do |framework|
      ENV["#{framework.upcase}_ENV"] = env.to_s unless env.nil?
    end
  else
    frameworks.each do |framework|
      variable_name = "#{framework.to_s.upcase}_ENV"
      ENV[variable_name] = env.to_s unless env.nil?
    end
  end
end

def reset_env framework=:all
  %w{rails rack app}.each do |type|
    set_env nil, framework
  end
end

describe Databasedotcom::Convenience do

  describe '.env' do
    before :each do
      reset_env
    end

    it 'returns :development if no variables are set' do
      set_env nil, :all
      Databasedotcom::Convenience.env.should == :development
    end

    it 'uses the rails environment first ' do
      set_env :production, :rails
      set_env :lies, :rack, :app

      Databasedotcom::Convenience.env.should == :production
    end

    it 'uses the rack environment second' do
      set_env nil, :rails
      set_env :production, :rack
      set_env :lies, :app
      Databasedotcom::Convenience.env.should == :production
    end

    it 'uses the app environment third' do
      set_env nil, :rails, :rack
      set_env :production, :app
      Databasedotcom::Convenience.env.should == :production
    end
  end

  class Klass
    include Databasedotcom::Convenience

    def reference_foo
      Foo.create
    end

    def reference_bar
      Bar.create
    end
  end

  describe ".dbdc_client" do
    after(:each) do
      Klass.dbdc_client = nil
    end

    describe "if the config has an entry that matches environment variables" do
      before (:each) do
        config_hash = { :production => { "client_id" => "production_client_id", "client_secret" => "production_client_secret",  "username" => "production_foo", "password" => "production_bar" },
          :development => { "client_id" => "development_client_id", "client_secret" => "development_client_secret",  "username" => "development_foo", "password" => "development_bar" },
          :test => { "client_id" => "test_client_id", "client_secret" => "test_client_secret",  "username" => "test_foo", "password" => "test_bar" }
        }

        YAML.should_receive(:load_file).and_return(config_hash)

        ::Databasedotcom::Convenience.stub!(:env).and_return(:production)
      end

      it "should use the corresponding entry" do
        Databasedotcom::Client.any_instance.should_receive(:authenticate).with(:username => "production_foo", :password => "production_bar")
        Klass.dbdc_client
      end
    end
    describe "if the config does not have an entry that matches Rails.env" do
      it "should use the top level config" do
        conf_hash = { "client_id" => "client_id", "client_secret" => "client_secret",  "username" => "foo", "password" => "bar" }
        ::Databasedotcom::Convenience.stub!(:env).and_return(:production)
        YAML.should_receive(:load_file).and_return(conf_hash)
        Databasedotcom::Client.any_instance.should_receive(:authenticate).with(:username => "foo", :password => "bar")
        Klass.dbdc_client
      end
    end

    describe "foo" do
      before(:each) do
        config_hash = { "client_id" => "client_id", "client_secret" => "client_secret",  "username" => "foo", "password" => "bar" }
        YAML.should_receive(:load_file).and_return(config_hash)
        ::Databasedotcom::Convenience.stub!(:env).and_return(:test)
      end

      it "constructs and authenticates a Databasedotcom::Client" do
        Databasedotcom::Client.any_instance.should_receive(:authenticate).with(:username => "foo", :password => "bar")
        Klass.dbdc_client
      end

      it "is memoized" do
        Databasedotcom::Client.any_instance.should_receive(:authenticate).exactly(1).times.with(:username => "foo", :password => "bar")
        Klass.dbdc_client
        Klass.dbdc_client
      end
    end
  end

  describe ".sobject_types" do
    before(:each) do
      @client_double = double("client")
      Klass.should_receive(:dbdc_client).any_number_of_times.and_return(@client_double)
    end

    after(:each) do
      Klass.instance_variable_set("@sobject_types", nil)
    end

    it "requests the sobject types from the client" do
      @client_double.should_receive(:list_sobjects)
      Klass.sobject_types
    end

    it "is memoized" do
      @client_double.should_receive(:list_sobjects).exactly(1).times.and_return(%w(foo bar))
      Klass.sobject_types
      Klass.sobject_types
    end
  end

  describe "#dbdc_client" do
    it "calls .dbdc_client" do
      Klass.should_receive(:dbdc_client)
      Klass.new.send(:dbdc_client)
    end
  end

  describe "#sobject_types" do
    it "calls .sobject_types" do
      Klass.should_receive(:sobject_types)
      Klass.new.send(:sobject_types)
    end
  end

  describe "automatic materialization" do
    before(:each) do
      @client_double = double("client")
      Klass.should_receive(:sobject_types).and_return(%w(Foo))
    end

    it "attempts to materialize a referenced constant that is a known sobject type" do
      Klass.should_receive(:dbdc_client).and_return(@client_double)
      @client_double.should_receive(:materialize).with("Foo").and_return(double("foo", :create => true))
      Klass.new.reference_foo
    end

    it "does not attempt to materialize a referenced constant that is not a known sobject type" do
      Klass.should_not_receive(:dbdc_client)
      expect {
        Klass.new.reference_bar
      }.to raise_error(NameError)
    end
  end
end
