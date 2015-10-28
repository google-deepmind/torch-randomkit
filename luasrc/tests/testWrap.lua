require "totem"
require 'randomkit'
local ffi = require 'ffi'

local myTest = {}
local tester = totem.Tester()

function myTest.testFFICall()
    local state = ffi.new('rk_state')
    state.torch_state = ffi.cast("THGenerator*", torch.pointer(torch._gen))
    randomkit.ffi.rk_seed(0, state)
    local x
    for i=1, 10 do
        tester:assert(tonumber(randomkit.ffi.rk_binomial(state, 10, 0.4)))
    end
end

function myTest.testWrappedCall()
    local N = 1000
    local x = torch.Tensor(N)
    local y = torch.Tensor(N)
    local state = torch.getRNGState()
    for i=1,N do
        x[i] = randomkit.binomial(10, 0.4)
    end
    torch.setRNGState(state)
    for i=1,N do
        y[i] = randomkit.binomial(10, 0.4)
    end
    tester:assertTensorEq(x,y,1e-16,'RK sequence is not a deterministic function of state')
    -- TODO: check distribtution

end


function myTest.callgetRNGWithGenerator()
    local generator = torch.Generator()
    local ok, msg = pcall( torch.getRNGState, generator)
    tester:assert(ok, 'Failed to get RNG state')
end

function myTest.callManualSeedWithGenerator()
    local generator = torch.Generator()
    local ok, msg = pcall( torch.manualSeed, generator,1)
    tester:assert(ok, 'Failed to set seed')
end


function myTest.callsetRNGWithGenerator()
    local generator = torch.Generator()
    local ok, state = pcall( torch.getRNGState, generator)
    tester:assert(ok, 'Failed to getRNG State')
    local ok, msg = pcall( torch.setRNGState, generator, state)
    tester:assert(ok, 'Failed to set RNG state')
end

function myTest.setRNGWithBadPointer()
  -- To simulate restoring the state from a previous run, we invalidate the
  -- pointer to the main Torch generator in a state that we are passing to
  -- setRNGState, and check that this doesn't break things.
  local state = torch.getRNGState()
  local x = tonumber(randomkit.binomial(10, 0.4))
  local badState = ffi.cast("rk_state *", state.randomkit)
  badState.torch_state = ffi.cast("THGenerator*", 0)
  torch.setRNGState{
      torch = state.torch,
      randomkit = badState
  }
  tester:asserteq(x, tonumber(randomkit.binomial(10, 0.4)))
end


tester:add(myTest)
return tester:run()
