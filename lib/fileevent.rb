#!/usr/bin/env ruby

require 'rubygems'
require 'statemachine'

class Event
    attr_reader :type, :time, :path, :hash
    
    def initialize(event)
        if event.size == 4
            @type = event[0]
            @time = Integer(event[1])
            @path = event[2]
            @hash = event[3]
        end
    end
end

class StateMachineContext
    attr_accessor :c_event, :l_event
    
    def initialize
        @c_event = Event.new(['',0,'',''])
    end
    
    def add_object
        obj = 'file'
        obj = 'folder' if @c_event.hash == '-'
        puts "Added #{obj} #{@c_event.path}"
    end
    
    def del_object
        obj = 'file'
        if @l_event.type == 'DEL'
            obj = 'folder' if @l_event.hash == '-'
            puts "Deleted #{obj} #{@l_event.path}"
        end
        obj = 'folder' if @c_event.hash == '-'
        puts "Deleted #{obj} #{@c_event.path}"
    end
    
    def move_object
        obj = 'file'
        obj = 'folder 'if @c_event.hash == '-' && @l_event.hash == '-'
        puts "Moved #{obj} #{@l_event.path} -> #{@c_event.path}"
    end
end

class FileEvent
    def initialize
        @events = Hash.new
    end
        
    def run
        sm = statemachine
        
        begin
            events = Integer(gets())
        rescue
            retry
        end
        
        while(events > 0)
            event = Event.new(gets().split(' '))
            
            sm.context.l_event = sm.context.c_event 
            sm.context.c_event = event
            
            if sm.context.c_event.time > sm.context.l_event.time
                sm.add if event.type == 'ADD'
                sm.del if event.type == 'DEL'
            end
            events-=1
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