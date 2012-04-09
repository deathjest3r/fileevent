require 'fileevent/events'

class EventMachineContext
    attr_accessor :c_events, :l_events
    
    def initialize
        @c_events = Events.new(Events::Event.new(['ADD',0,'/','-']))
    end
    
    def add_object
        @c_events.each do |event|
            obj = 'file'
            obj = 'folder' if event.hash == '-'
            puts "Added #{obj} #{event.path}"
        end
    end
    
    def del_object
        @l_events.each do |event|
            obj = 'file'
            obj = 'folder' if event.hash == '-'
            puts "Deleted #{obj} #{event.path}"
        end
    end
    
    def move_object
        if @c_events == @l_events
            obj = 'folder'
            puts "Moved #{obj} #{@l_events.root} -> #{@c_events.root}"
        else
            del_object
            add_object
        end
    end
end

class EventMachine
    attr_reader :eventmachine
    
    def initialize
        @eventmachine = Statemachine.build do
            
            state :stage0 do
                event :del, :stage1
                event :add, :stage0, :add_object 
            end
            state :stage1 do
                event :del, :stage1, :del_object
                event :add, :stage0, :move_object   
            end
            context EventMachineContext.new
        end
    end
end