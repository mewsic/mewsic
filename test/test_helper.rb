ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'redgreen' unless ENV["TM_MODE"]
require 'fixture_helpers'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  # If you need to control the loading order (due to foreign key constraints etc), you'll
  # need to change this line to explicitly name the order you desire.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def deny(assertion)
    assert !assertion
  end
  
  def assert_acts_as_rated(klass)
    rated_object = klass.constantize.find :first
    deny rated_object.rated?
    rated_object.rate(4, users(:quentin))
    assert rated_object.reload.rated?
    assert_equal 4.0, rated_object.rating_average
  end

  def assert_x_accel_redirect(options)
    assert_response :success
    assert @response.body.blank?
    assert_equal options[:filename], @response.headers['X-Accel-Redirect']
    # ActionController::Integration oddities
    assert (@response.headers['Content-Type'] || @response.headers['type']) =~ /^#{options[:content_type]}/
  end

  def setup_sphinx
    return if $sphinx_config

    $sphinx_config = File.join(RAILS_ROOT, 'config', 'sphinx_test.config')
    File.open($sphinx_config, 'w+') do |config|
      template = File.read(File.join(RAILS_ROOT, 'config', 'sphinx.config.erb'))
      config.write ERB.new(template).result
    end unless File.exists? $sphinx_config

    `searchd --config #{$sphinx_config.sub('test', 'development')} --stop`

    `indexer --config #$sphinx_config --all`
    `searchd --config #$sphinx_config`

    at_exit do
      `searchd --config #$sphinx_config --stop`
      `searchd --config #{$sphinx_config.sub('test', 'development')}`
    end
  end

end
