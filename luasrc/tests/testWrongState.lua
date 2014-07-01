require "totem"

local seedTest = {}
local tester = totem.Tester()

function seedTest.testStateBeforeRequire()
    if randomkit then
        print('Randomkit already loaded, skipping test, please run individually')
        return
    end
    local state = torch.getRNGState()
    require 'randomkit'
    tester:assertError(function() torch.setRNGState(state) end, 'Failed to generate error')
    tester:assertErrorPattern(function() torch.setRNGState(state) end, '.*State was not saved with randomkit, cannot set it back.*', 'Generated wrong error')
end


tester:add(seedTest)
return tester:run()
