--[[
    UI队列
--]]

ui = ui or {};

local QueueNode = class("QueueNode");
function QueueNode:ctor(func)
    self.isCompleted = false;
    self.isRunnging = false;
end

function QueueNode:run()
    
end

function QueueNode:completed()
    self.isCompleted = true;
end

--[[
    Queue
--]]
local Queue = class("UIQueue");
function Queue:ctor()
    self.queue = {};
    self.isStartRun = false;
    coli.eventManager.addObserver(self, coli.Events.E_Queue_Finish_One);
end

function Queue:clear()
    -- coli.eventManager.removeObserver(self, coli.Events.E_Queue_Finish_One);
    self.queue = {};
    self.isStartRun = false;
end

function Queue:handleEvent(event, params)
    if event == coli.Events.E_Queue_Finish_One then
        local top = self:front();
        if top then
            top:completed();
        end
    end
end

function Queue:add(node)
    table.insert(self.queue, node);
end

function Queue:front()
    return self.queue[1];
end

function Queue:pop()
    table.remove(self.queue, 1);
end

function Queue:isEmpty()
    return #self.queue <= 0;
end

function Queue:start()
    self.isStartRun = true;
end

function Queue:run()
    if self:isEmpty() or not self.isStartRun then
        return;
    end

    local top = self:front()
    if top then
        if top.isCompleted then
            self:pop();
        else
            top:run();
        end
    end
end

ui.Queue = Queue;
ui.QueueNode = QueueNode;