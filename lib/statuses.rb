#  (C) 2009 Marcello Barnaba <vjt@openssl.it>
# Released under the terms of the MIT License
#
module MultipleStatuses
  def self.included(target)
    target.extend ClassMethods
  end

  module ClassMethods
    def has_multiple_statuses(statuses_hash)
      write_inheritable_attribute :statuses, statuses_hash
      class_inheritable_reader :statuses

      statuses_hash.each do |name, status|
        # Defines a query method on the model instance, one
        # for each status name (e.g. Song#published?)
        define_method("#{name}?") { self.read_attribute(:status) == status }

        # Defines on the `statuses` object a method for
        # each status name. Each return the status value.
        # So you can do both statuses[:public] and statuses.public
        #
        class<<statuses;self;end.send(:define_method, name) { status }
      end

      include InstanceMethods
    end
  end

  module InstanceMethods
    def status(format = nil)
      status = read_attribute :status
      if format == :db
        status
      else
        statuses.invert[status]
      end
    end

    def status=(value)
      if statuses.has_key? value
        write_attribute :status, statuses[value]
      elsif statuses.values.include? value
        write_attribute :status, value
      else
        raise ActiveRecord::ActiveRecordError, "invalid status #{value.inspect}"
      end
    end

  end
end

ActiveRecord::Base.send :include, MultipleStatuses
