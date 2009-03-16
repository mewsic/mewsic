$:.unshift(File.dirname(__FILE__) + '/../lib')
plugin_spec_dir = File.dirname(__FILE__)

require 'rubygems'
require 'active_record' 
require 'spec'

RAILS_DEFAULT_LOGGER = Logger.new(plugin_spec_dir + "/debug.log")
ActiveRecord::Base.logger = RAILS_DEFAULT_LOGGER

require plugin_spec_dir + '/../init.rb'

ActiveRecord::Base.configurations = YAML::load(IO.read(plugin_spec_dir + "/db/database.yml"))
ActiveRecord::Base.establish_connection(ENV["DB"] || "sqlite3")
ActiveRecord::Migration.verbose = false
load(File.join(plugin_spec_dir, "db", "schema.rb"))

module Spec::Example::ExampleGroupMethods
  alias :context :describe
end

class TaggableModel < ActiveRecord::Base
  acts_as_taggable_on :tags, :languages
  acts_as_taggable_on :skills
end

class OtherTaggableModel < ActiveRecord::Base
  acts_as_taggable_on :tags, :languages
end

class InheritingTaggableModel < TaggableModel
end

class AlteredInheritingTaggableModel < TaggableModel
  acts_as_taggable_on :parts
end

class TaggableUser < ActiveRecord::Base
  acts_as_tagger
end

class UntaggableModel < ActiveRecord::Base
end