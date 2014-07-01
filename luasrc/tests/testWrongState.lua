require "totem"

local seedTest = {}
local tester = totem.Tester()

function seedTest.testStateBeforeRequire()
    local state = torch.getRNGState()
    require 'randomkit'
    tester:assertError(function() torch.setRNGState(state) end, 'Failed to generate error')
    tester:assertErrorPattern(function() torch.setRNGState(state) end, '.*State was not saved with randomkit, cannot set it back.*', 'Generated wrong error')
end


tester:add(seedTest)
return tester:run()
