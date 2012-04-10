#!/usr/bin/env ruby
$: << File.expand_path(File.dirname(__FILE__) + "/../lib")

require 'rubygems'
require 'statemachine'

require 'fileevent/eventmachine'
require 'fileevent/events'

class FileEvent
    def initialize
        @events = Hash.new
        @em = EventMachine.new.eventmachine
        @context = @em.context
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
                new_event = Events::Event.new(gets().split(' '))
            rescue => e
                puts 'Unknown event...'
                next
            end
                            
            if new_event.time > @context.c_events.time
                @em.add if @context.c_events.type == 'ADD'
                @em.del if @context.c_events.type == 'DEL'
                
                @context.l_events = @context.c_events 
                @context.c_events = Events.new(new_event)
                
                
    
            elsif @context.c_events.time == new_event.time 
                @context.c_events << new_event
            end            
        end
        
        if @em.state == :stage1    
            @context.c_events.each do |event|
                obj = 'file'
                obj = 'folder' if event.hash == '-'
                puts "Deleted #{obj} #{event.path}"
            end
        end
    end
end

fe = FileEvent.new
fe.run