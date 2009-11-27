module ActionAuditor
  def self.auditors
    @@auditors ||= []
  end
  
  def self.auditors=(auditors)
    @@auditors = Array(auditors)
  end
  
  def self.log(message, parameters = {})
    auditors.each { |auditor| auditor.log(message, parameters) }
  end
end
