# require "action_auditor"

ActionController::Base.send :include, ActionAuditor::Extensions::ActionController
