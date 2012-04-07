#!/usr/bin/env ruby

require 'rubygems'
require 'statemachine'

class Event
    attr_reader :type, :time, :path, :hash
    
    def initialize(event)
        if args.size == 4
            @type = args[0]
            @time = Integer(args[1])
            @path = args[2]
            @hash = args[3]
        end
    end
end

class StateMachineContext
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

class FileEvent
    def initialize
        @events = Hash.new
    end
        
    def run
        begin
            events = Integer(gets())
        rescue
            retry
        end
        
        while(events > 0)
            begin
                event = Event.new(gets().split(' '))
            rescue
            end
                
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

            sm.add if @events[time][0].type == 'ADD'
            sm.del if @events[time][0].type == 'DEL'
        end
        
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

fe = FileEvent.new
fe.run