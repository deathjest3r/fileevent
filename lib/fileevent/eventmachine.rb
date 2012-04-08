
class EventMachineContext
    attr_accessor :sm, :c_event, :l_event
    
    def initialize
    end
    
    def add_object
        obj = 'file'
        obj = 'folder' if @c_event.hash == '-'
        puts "Added #{obj} #{@c_event.path}"
    end
    
    def del_object
        if @l_event.type == 'DEL'
            obj = 'file'
            obj = 'folder' if @c_event.hash == '-'
            puts "Deleted #{obj} #{@l_event.path}"
        end
        obj = 'file'
        obj = 'folder' if @c_event.hash == '-'
        puts "Deleted #{obj} #{@c_event.path}"
    end
    
    def move_object
        obj = 'file'
        obj = 'folder' if @c_event.hash == '-' && @l_event.hash == '-'
        puts "Moved #{obj} #{@l_event.path} -> #{@c_event.path}"
    end
    
    def verify_event(events)
        if events.size > 1
        else
            @sm.del if events[0].type == 'ADD'
            @sm.add if events[0].type == 'DEL'
        end
    end
    
end

class EventMachine
    attr_reader :eventmachine
    
    def initialize
        @eventmachine = Statemachine.build do
            
            superstate :operational do
                state :stage0 do
                    event :del, :stage1
                    event :add, :stage0, :add_object 
                end
                state :stage1 do
                    event :del, :stage0, :del_object
                    event :add, :stage2
                    
                end
                state :stage2 do
                    event :add, :stage0, :add_object
                    event :del, :stage0, :del_object
                end
                
                event :verify, :stageV, :verify_event
            end
            
            trans :stageV, :verified, :operational_H
            trans :stage1, :add, :stage2, :move_object
            
            context EventMachineContext.new
        end
        @eventmachine.context.eventmachine = @eventmachine
    end
end