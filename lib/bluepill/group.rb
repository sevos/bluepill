module Bluepill
  class Group
    attr_accessor :name, :processes, :logger
    attr_accessor :process_logger
    
    def initialize(name, options = {})
      self.name = name
      self.processes = []
      self.logger = options[:logger]
      
      if self.logger
        logger_prefix = self.name ? "#{self.name}:" : nil
        self.process_logger = Bluepill::Logger.new(self.logger, logger_prefix) 
      end
    end
    
    def add_process(process)
      process.logger = self.process_logger
      self.processes << process
    end
    
    def tick
      self.each_process do |process|
        process.tick
      end
    end
    
    def start
      self.each_process do |process|
        process.dispatch!("start")
      end
    end
    
    def unmonitor
      self.each_process do |process|
        process.dispatch!("unmonitor")
      end
    end
    
    def stop(process_name = nil)
      self.each_process do |process|
        process.dispatch!("stop") if process_name.nil? || process.name == process_name
      end
    end
    
    def status
      status = []
      self.each_process do |process|
        status << [process.name, process.state]
      end
      status
    end
    
    
    protected
    def each_process(&block)
      self.processes.each(&block)
    end
  end
end