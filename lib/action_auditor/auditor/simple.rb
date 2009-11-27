module ActionAuditor
  module Auditor
    # The simplest possible implementation of an auditor.
    # Simply maintains a list of [message, hash] pairs,
    # with no persistence.
    # This is mainly of use for testing.
    class Simple < Base
      class LoggedAction < Struct.new(:message, :parameters)
        
      end
      
      def initialize
        @messages = []
      end
      
      def clear!
        @messages = []
      end
      
      def log(message, parameters = {})
        @messages << LoggedAction.new(message, parameters)
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