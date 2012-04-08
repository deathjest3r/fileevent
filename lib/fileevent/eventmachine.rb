
class EventMachineContext
    attr_accessor :c_event, :l_event
    
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
end

class EventMachine
    attr_reader :sm
    
    def initialize
        @sm = Statemachine.build do
            state :stage0 do
                event :del, :stage1
                event :add, :stage0, :add_object 
            end
            state :stage1 do
                event :add, :stage2
                event :del, :stage0, :del_object
                
            end
            state :stage2 do
                event :add, :stage0, :add_object
                event :del, :stage0, :del_object
                on_entry :move_object
            end
            
            context EventMachineContext.new
        end
    end
end