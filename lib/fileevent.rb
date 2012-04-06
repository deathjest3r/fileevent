#!/usr/bin/env ruby

class Event
    attr_reader :type, :time, :path, :hash
    
    def initialize(*args)
        if args.size == 1
            @type = args[0][0]
            @time = args[0][1]
            @path = args[0][2]
            @hash = args[0][3]
        end
    end
end

class EventFolder
    attr_reader :path
    attr_accessor :files
    
    def initialize(event)
        @path = event.path
        @files = Hash.new
        @events = [event]
    end
    
    # Events noch zeitlich sortieren
    def add_event(event)
        @events << event
    end
    
    def is_empty
        return true if @files.empty?
        return false
    end
end

class EventFile
    attr_reader :hash, :parent
    
    def initialize(event)
        # Exception werfen falls split fehlschlaegt
        @hash = event.hash
        @parent = File.dirname(event.path)
        @events = [event]
    end
    
    # Events noch zeitlich sortieren
    def add_event(event)
        @events << event
    end
    
    def handle_events
        @events.each_with_index do |evt, idx|
            # Jump to next event if event is nil
            next if evt == nil
            # Check if first event is an ADD event, otherwise discard
            @events[idx] = nil if idx == 0 && evt.type == 'DEL'
            # Send msg, for creation of an element
            puts "Added file #{evt.path}." if idx == 0 && evt.type == 'ADD'
            
            
            if idx > 0 && @events[idx-1].type == 'DEL' && evt.type == 'ADD'
                puts "File moved #{@events[idx-1].path} -> #{evt.path}."
            end
            
            if idx > 0 && @events[idx-1].type == 'ADD' && evt.type == 'ADD'
                puts "File copied #{@events[idx-1].path} -> #{evt.path}."
            end  
        end
    end
end

class FileEvent
    def initialize
        @folders = Hash.new
    end
        
    def parse_events(e)
        event = Event.new(e.split(' '))
        
        if event.hash == '-'
            folder = EventFolder.new(event)
            
            if @folders[folder.path] == nil
                @folders[folder.path] = folder
            else
                @folders[folder.path].add_event(event)
            end
        else
            file = EventFile.new(event)
            
            # Created file without folder...
            return if @folders[file.parent] == nil
            
      
            if @folders[file.parent].files[file.hash] == nil
                @folders[file.parent].files[file.hash] = file
            else
                @folders[file.parent].files[file.hash].add_event(event)
            end
        end  
    end
    
    def run
        begin
            events = Integer(gets())
        rescue
            puts 'Unknown event count'
            retry
        end
        
        while(events > 0)
            parse_events(gets())
            events-=1
        end
        
#        @folders.each do |hash, file|
#            #puts hash
#            file.handle_events
#        end
    end
end

def main
    fe = FileEvent.new
    fe.run
end

main
