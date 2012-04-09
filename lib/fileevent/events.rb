class Events
    attr_reader :type, :time, :root
    
    def initialize(event)
        
        @type = event.type
        @time = event.time
        @root = event.path
        
        self << event
    end
    
    def <<(event)
        return if event.type != @type || event.time != @time
        
        @events = Array.new if @events == nil
        
        if event.path.count('/') < @root.count('/')
            @root = event.path[0]
        end
        
        @events << event
    end
    
    def ==(events)       
        if (content & events.content).size == content.size &&
              (hashes & events.hashes).size == hashes.size
            return true
        end
        return false
    end
    
    def each
        @events.each do |event|
            yield event
        end
    end
    
    def hashes
        h = Array.new
        self.each do |event|
            h << event.hash 
        end
        return h
    end
    
    def content
        c = Array.new  
        self.each do |event|
            file = (event.path.split('/') - @root.split('/'))[0]
            c << file if file != nil
        end
        return c
    end
    
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
end