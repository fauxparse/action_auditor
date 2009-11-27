module ActionAuditor
  module Auditor
    class ActiveRecord < Base
      class LoggedAction < ::ActiveRecord::Base
        set_table_name "logged_actions"

        serialize :parameters
      end
      
      def clear!
        LoggedAction.destroy_all
      end
      
      def log(message, parameters = {})
        LoggedAction.create :message => message, :parameters => parameters
      end
      
      def size
        LoggedAction.count
      end
      
      def last
        LoggedAction.last
      end
    end
  end
end