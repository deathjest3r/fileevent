#!/usr/bin/env ruby
$: << File.expand_path(File.dirname(__FILE__) + "/../lib")

require 'rubygems'
require 'statemachine'

require 'fileevent/eventmachine'

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


class FileEvent
    def initialize
        @events = Hash.new
    end
        
    def run
        begin
            events = Integer(gets())
        rescue => e
            puts "Error: #{e.message}"
            return
        end
        
        events.times do 
            begin
                event = Event.new(gets().split(' '))
            rescue => e
                next
            end
                
            if @events[event.time] == nil
                @events[event.time] = [event] 
            else
                @events[event.time] << event
            end
        end
        
        exec_events
    end
    
    def sort_events
        @events.each do |time, event_array| 
            if event_array.size > 1
                event.array.each do
                end
            end
        end
    end
        
    def exec_events
        sm = EventMachine.new.eventmachine
        
        times = @events.keys.sort
        times.each do |time|
            next if @events[time] == nil 
            
            sm.context.l_event = sm.context.c_event 
            sm.context.c_event = @events[time][0]
            
            sm.verify @events[time]
            sm.verified

            #sm.add if @events[time][0].type == 'ADD'
            #sm.del if @events[time][0].type == 'DEL'
        end
        
        if sm.state == :stage1
            sm.context.del_object
        end
    end
    
    
end

fe = FileEvent.new
fe.run