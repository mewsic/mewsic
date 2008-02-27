ActiveRecord::Base.class_eval do
  def self.find(*args)
    options = args.extract_options!
    validate_find_options(options)
    set_readonly_option!(options)

    case args.first
      when :first then find_initial(options)
      when :all   then find_every(options)
      when :random then find_random(options)
      else             find_from_ids(args, options)
    end
  end
  
  protected
  def self.find_random(options)
    raise "Cannot use :order in find :random" if options.has_key? :order
    exist = self.columns.find{|column| column.name == 'activated_at'}

    conditions = options.delete(:conditions)
    limit = options.delete(:limit)
    
    qry = "select id from #{table_name}"
    qry += " where #{conditions}"   if (exist and conditions)
    qry += " order by "
    
    if connection.class.to_s == "ActiveRecord::ConnectionAdapters::SQLite3Adapter"
      qry += 'random()'
    elsif connection.class.to_s == "ActiveRecord::ConnectionAdapters::MysqlAdapter"
      qry += 'rand()'
    else
      raise "Unsupported adapter for random extraction."
    end
    
    qry += " limit #{limit}" if limit
    find(connection.select_values(qry), options)    
  end

end