connection = ActiveRecord::Base.connection
SQL_RANDOM_FUNCTION = if connection.class.to_s == "ActiveRecord::ConnectionAdapters::SQLite3Adapter"
  'random()'
elsif connection.class.to_s == "ActiveRecord::ConnectionAdapters::MysqlAdapter"
  'rand()'
else
  raise "Unsupported adapter for random extraction."
end
