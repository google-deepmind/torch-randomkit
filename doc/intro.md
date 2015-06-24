#Randomkit random number generators, wrapped for Torch

Provides and wraps the Randomkit library, copied from Numpy

##Example

###Single sample

You can call any of the wrapped functions with just the distribution's parameters to generate a single sample and return a number:

    require 'randomkit'
    randomkit.poisson(5)

###Multiple samples from one distribution

Often, you might want to generate many samples identically distributed. Simply pass as a first argument a tensor of the proper dimension, into which the samples will be stored:

    x = torch.Tensor(10000)
    randomkit.poisson(x, 5)

The sampler returns the tensor, so you can shorten the above in:

    x = randomkit.poisson(torch.Tensor(10000), 5)

###Multiple samples from multiple distributions

Finally, you might want to generate many samples, each from a distribution with different parameters. This is achieved by passing a Tensor as the parameter of the distribution:

    many_lambda = torch.Tensor{5, 3, 40, 60}
    x = randomkit.poisson(many_lambda)

Of course, this can be combined with passing a result Tensor as an optional first element, to re-use memory and avoid creating a new Tensor at each call:

    many_lambda = torch.Tensor{5, 3, 40, 60}
    x = torch.Tensor(many_lambda:size())
    randomkit.poisson(x, many_lambda)

Note: in the latter case, the size of the result Tensor must correspond to the size of the parameter tensor -- we do not resize the result tensor automatically, yet:

###Getting/setting the seed and the state

Randomkit is transparently integrated with Torch's random stream: just use torch.manualSeed(seed), torch.getRNGState(), and torch.setRNGState(state) as usual.
Specifying an (optional) torch.Generator instance as the first argument will only influence the state of that generator, leaving the state of randomkit unchanged.

##Installation

From a terminal:
    
    torch-rocks install randomkit


##Unit Tests

Last but not least, the unit tests are in the folder
luasrc/tests. You can run them from your local clone of the repository with:
git clone https://www.github.com/jucor/torch-randomkit

    find torch-randomkit/luasrc/tests -name "test*lua" -exec torch {} \;

##Direct access to FFI

randomkit.ffi.*

Functions directly accessible at the top of the randomkit table are Lua wrappers to the actual C functions from Randomkit, with extra error checking. If, for any reason, you want to get rid of this error checking and of a possible overhead, the FFI-wrapper functions can be called directly via randomkit.ffi.myfunction() instead of randomkit.myfunction().