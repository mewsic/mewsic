# (C) 2009 Marcello Barnaba <vjt@openssl.it>
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
        define_method("#{name}?") { self.status == status }

        # Defines on the `statuses` object a method for
        # each status name. Each return the status value.
        # So you can do both statuses[:public] and statuses.public
        #
        class<<statuses;self;end.send(:define_method, name) { status }
      end
    end
  end

  module InstanceMethods
  end
end

ActiveRecord::Base.send :include, MultipleStatuses
