#!/usr/bin/env ruby

require 'rubygems'
require 'statemachine'

class Event
    attr_reader :type, :time, :path, :hash
    
    def initialize(*args)
        if args.size == 1
            @type = args[0][0]
            @time = Integer(args[0][1])
            @path = args[0][2]
            @hash = args[0][3]
        end
    end
end

class StateMachineContext
    attr_accessor :c_event, :l_event
    
    def initialize
    end
    
    def add_object
        if @c_event.hash == '-'
            puts "Added folder #{@c_event.path}"
        else
            puts "Added file #{@c_event.path}"
        end
    end
    
    def del_object
        if @l_event.type == 'DEL'
            if @l_event.hash == '-'
                puts "Deleted folder #{@l_event.path}"
            else
                puts "Deleted file #{@l_event.path}"
            end
        end
        if @c_event.hash == '-'
            puts "Deleted folder #{@c_event.path}"
        else
            puts "Deleted file #{@c_event.path}"
        end
    end
    
    def move_object
        if @c_event.hash == '-' && @l_event.hash == '-'
            puts "Moved folder #{@l_event.path} -> #{@c_event.path}"
        else
            puts "Renamed file #{@l_event.path} -> #{@c_event.path}"
        end
    end
end

class FileEvent
    def initialize
        @events = Hash.new
    end
        
    def run
        begin
            events = Integer(gets())
        rescue
            puts 'Unknown event count'
            retry
        end
        
        while(events > 0)
            event = Event.new(gets().split(' '))

            if @events[event.time] == nil
                @events[event.time] = [event] 
            else
                @events[event.time] << event
            end
            events-=1
        end
        
        exec_events
    end
        
    def exec_events
        sm = statemachine
        
        times = @events.keys.sort
        times.each do |time|
            sm.context.l_event = sm.context.c_event 
            sm.context.c_event = @events[time][0]

            if @events[time][0].type == 'ADD'
                sm.add
            elsif @events[time][0].type == 'DEL'
                sm.del
            end
        end
        
        # When final event is del, handle it...
        if sm.state == :stage1
            sm.context.del_object
        end
    end
    
    def statemachine
        sm = Statemachine.build do
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
            
            
            context StateMachineContext.new
        end
        return sm
    end
end

def main
    fe = FileEvent.new
    fe.run
end

main
