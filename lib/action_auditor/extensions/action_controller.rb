module ActionAuditor
  module Extensions
    module ActionController
      module ClassMethods
        def audit(*args, &block)
          options = args.last.is_a?(Hash) ? args.pop : {}
          @pending_auditor = [ args, options, block ]
        end
        
        def method_added_with_auditing(name)
          method_added_without_auditing(name)
          if @pending_auditor
            auditors[name.to_sym] = @pending_auditor
            @pending_auditor = nil
          end
        end
      end
      
      def audit_last_action
        if auditor = self.class.auditors[action_name.to_sym]
          args, options, block = auditor
          parameters = {}
          log_message = if block.arity.zero?
            block.call
          else
            block.call parameters
          end
          
          ActionAuditor.log(log_message, parameters)
        end
      end
      protected :audit_last_action
      
      def self.included(receiver)
        receiver.extend ClassMethods
        
        receiver.class_eval do
          class_inheritable_accessor :auditors
          self.auditors = {}
          
          class << receiver
            alias_method_chain :method_added, :auditing
          end
          
          after_filter :audit_last_action
        end
      end
    end
  end
end