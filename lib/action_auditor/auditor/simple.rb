module ActionAuditor
  module Auditor
    # The simplest possible implementation of an auditor.
    # Simply maintains a list of [message, hash] pairs,
    # with no persistence.
    # This is mainly of use for testing.
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