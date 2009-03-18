ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'redgreen' unless ENV["TM_MODE"]
require 'fixture_helpers'
require 'rexml/document'

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

  def assert_commentable(object, options = {})
    comment = object.comments.create(:body => 'Just a test')
    count = object.comments_count

    comment.user = users(options[:by] || :quentin)
    assert comment.valid?
    assert_nothing_raised { comment.save! }

    comment.reload

    assert_equal 'Just a test', comment.body
    assert_equal object, comment.commentable
    assert_equal count + 1, object.reload.comments_count

    return comment
  end

  def assert_x_accel_redirect(options, &block)

    @request.env['SERVER_SOFTWARE'] = 'Nginx 0.6.17'
    block.call
    assert_download_acceleration_header options.merge(:header => 'X-Accel-Redirect')

    @request.env['SERVER_SOFTWARE'] = 'Apache/2.2.8 (Ubuntu) Phusion_Passenger/2.0.5'
    block.call
    assert_download_acceleration_header options.merge(:header => 'X-Sendfile', :filename => File.join(RAILS_ROOT, 'public', options[:filename]))

    @request.env['SERVER_SOFTWARE'] = 'Mongrel'
    block.call
    assert_response :success
    deny @response.body.blank?

  end

  def assert_blank_response(code = :success)
    assert_response code
    assert @response.body.blank?
  end

  def assert_download_acceleration_header(options)
    assert_response :success
    assert_blank_response
    assert_equal options[:filename], @response.headers[options[:header]]
    # ActionController::Integration oddities
    assert (@response.headers['Content-Type'] || @response.headers['type']) =~ /^#{options[:content_type]}/
  end

  def assert_valid_podcast(options = {})
    xml = REXML::Document.new(@response.body)
    assert_not_nil xml

    assert_equal 1, REXML::XPath.match(xml, "//channel").size
    assert_equal options[:nitems], REXML::XPath.match(xml, "//title").size
    assert_equal 0, REXML::XPath.match(xml, "//non_existing_element").size
  end

  def assert_valid_pcast
    xml = REXML::Document.new(@response.body)
    assert_not_nil xml

    assert_equal 1, REXML::XPath.match(xml, "//pcast").size
    assert_equal 0, REXML::XPath.match(xml, "//non_existing_element").size
  end

  def assert_valid_rss(options = {})
    xml = REXML::Document.new(@response.body)
    assert_not_nil xml

    assert_equal 1, REXML::XPath.match(xml, '/rss').size
    assert_equal 1, REXML::XPath.match(xml, '/rss/channel').size
    assert_equal 1, REXML::XPath.match(xml, '/rss/channel/title').size
    assert_equal 1, REXML::XPath.match(xml, '/rss/channel/link').size
    assert_equal 1, REXML::XPath.match(xml, '/rss/channel/description').size
    assert_equal 1, REXML::XPath.match(xml, '/rss/channel/pubDate').size

    nitems = REXML::XPath.match(xml, '/rss/channel/item').size

    if options[:nitems]
      assert_equal options[:nitems], nitems
    else
      assert nitems > 0
    end
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
