module ActionAuditor
  module Auditor
    class Simple < Base
      def initialize
        @messages = []
      end
      
      def clear!
        @messages = []
      end
      
      def log(message, parameters = {})
        @messages << [ message, parameters ]
      end
      
      def size
        @messages.size
      end
      
      def last
        @messages.last
      end
    end
  end
end