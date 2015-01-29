require "totem"
local myTests = {}
local tester = totem.Tester()

function myTests.test_beta()
    local N = 10000
    local oneRequire = torch.Tensor(N)
    local multipleRequire = torch.Tensor(N)


    -- Call N in one go
    require 'randomkit'
    local state = torch.getRNGState()
    randomkit.gauss(oneRequire)

    -- call N with require between each another
    torch.setRNGState(state)
    local multipleRequire = torch.Tensor(N)
    for i=1,N do
        require 'randomkit'
        multipleRequire[i] = randomkit.gauss()
    end

    -- The streams should be the same
    tester:assertTensorEq(oneRequire, multipleRequire, 1e-16, 'Multiple require changed the stream')

end

tester:add(myTests)
return tester:run()
