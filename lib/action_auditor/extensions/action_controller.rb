module ActionAuditor
  module Extensions
    module ActionController
      module ClassMethods
        def audit(*args, &block)
          options = args.last.is_a?(Hash) ? args.pop : {}
          @pending_auditor = [ args, options, block_given? ? block : args.first ]
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
          args, options, block_or_message = auditor
          parameters = {}
          
          log_message, parameters = case block_or_message
          when String then [ block_or_message, {} ]
          when Proc
            values = Array(instance_eval(&block_or_message))
            values << {} if values.size < 2
            values[0,2]
          end
          
          log_message.gsub!(/\{\{(\w+)\}\}/) { parameters[$1.to_sym].to_s }
          
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