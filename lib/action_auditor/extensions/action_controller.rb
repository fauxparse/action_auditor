module ActionAuditor
  module Extensions
    module ActionController
      module ClassMethods
        # Set up an audit trail for the next action defined.
        # This is similar to +desc+ in a Rake task: you call it
        # immediately before the action.
        #
        # == Simple messages
        # This will log "hello, world" each time someone
        # visits the +index+ page.
        #     class PostsController < ApplicationController
        #       audit "hello, world"
        #       def index
        #       end
        #     end
        #
        # == Blocks
        # If you need to interpolate any information at runtime,
        # you'll need to use a block:
        #     class PostsController < ApplicationController
        #       audit { "#{current_user} stopped by" }
        #       def index
        #       end
        #     end
        # ...otherwise the string will get evaluated when the
        # controller class is defined.
        #
        # == Parameters
        # If you need to save any information besides a message,
        # you can write a block that returns [+message+, +params+],
        # where +params+ is a hash of objects:
        #     class PostsController < ApplicationController
        #       audit {[
        #         "{{user}} created {{post}}",
        #         { :user => current_user, :post => @post }
        #       ]}
        #       def create
        #         @post = Post.create(params[:post])
        #       end
        #     end
        # Notice that you can interpolate these parameters
        # within your log message.
        #
        # It's up to the individual auditors how your parameters
        # are saved — and, indeed, whether they're saved at all.
        # An ActiveRecord implementation might serialize the
        # objects, or just their IDs, while a text-only auditor
        # might discard them completely. You should not rely on
        # having access to these parameters later on, unless
        # you know how and where they are saved.
        def audit(*args, &block)
          options = args.last.is_a?(Hash) ? args.pop : {}
          block_or_message = block_given? ? block : args.shift
          @pending_auditor = [ args, options, block_or_message ]
        end
        
        def method_added_with_auditing(name) #:nodoc:
          method_added_without_auditing(name)
          if @pending_auditor
            auditors[name.to_sym] = @pending_auditor
            @pending_auditor = nil
          end
        end
      end
      
      # Filter method called after each action.
      # Checks if there's any auditing set up for this
      # action, then logs relevant information using
      # any active auditors.
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
      
      def self.included(receiver) #:nodoc:
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