---
title: Randomkit RNG for Torch
layout: doc
---

#Randomkit random number generators, wrapped for Torch

Provides and wraps the random nnumber generators the [Randomkit library](), copied from [Numpy]()

##Example

###Single sample

You can call any of the wrapped functions with just the distribution's parameters to generate a single sample and return a number:

```lua
require 'randomkit'
randomkit.poisson(5)
```

###Multiple samples from one distribution

Often, you might want to generate many samples identically distributed. Simply pass as a first argument a tensor of the proper dimension, into which the samples will be stored:

```lua
x = torch.Tensor(10000)
randomkit.poisson(x, 5)
```

The sampler returns the tensor, so you can shorten the above in:

```lua
x = randomkit.poisson(torch.Tensor(10000), 5)
```

###Multiple samples from multiple distributions

Finally, you might want to generate many samples, each from a distribution with different parameters. This is achieved by passing a Tensor as the parameter of the distribution:

```lua
many_lambda = torch.Tensor{5, 3, 40, 60}
x = randomkit.poisson(many_lambda)
```

Of course, this can be combined with passing a result Tensor as an optional first element, to re-use memory and avoid creaating a new Tensor at each call:

```lua
many_lambda = torch.Tensor{5, 3, 40, 60}
x = torch.Tensor(many_lambda:size())
randomkit.poisson(x, many_lambda)
```

**Note:** in the latter case, the size of the result Tensor must correspond to the size of the parameter tensor -- we do not resize the result tensor automatically, yet:

###Getting/setting the seed and the state

Randomkit is transparently integrated with Torch's random stream: just use `torch.manualSeed(seed)`, `torch.getRNGState()`, and `torch.setRNGState(state)` as usual.
Specifying an (optional) torch.Generator instance as the first argument will only influence the state of that genereator, leaving the state of randomkit unchanged.

##Installation

From a terminal:

```bash
torch-rocks install randomkit
```

##List of Randomkit generators

See this **[extensive automatically extracted doc](randomkit.html)**, built from Numpy's docstrings.

###[Beta](randomkit.html#beta)
###[Binomial](randomkit.html#binomial)
###[Bytes](randomkit.html#bytes)
###[Chisquare](randomkit.html#chisquare)
###[Double](randomkit.html#double)
###[Exponential](randomkit.html#exponential)
###[F](randomkit.html#f)
###[Gamma](randomkit.html#gamma)
###[Gauss](randomkit.html#gauss)
###[Geometric](randomkit.html#geometric)
###[Gumbel](randomkit.html#gumbel)
###[Hypergeometric](randomkit.html#hypergeometric)
###[Interval](randomkit.html#interval)
###[Laplace](randomkit.html#laplace)
###[Logistic](randomkit.html#logistic)
###[Lognormal](randomkit.html#lognormal)
###[Logseries](randomkit.html#logseries)
###[Long](randomkit.html#long)
###[Negative binomial](randomkit.html#negative_binomial)
###[Noncentral chisquare](randomkit.html#noncentral_chisquare)
###[Noncentral F](randomkit.html#noncentral_f)
###[Normal](randomkit.html#normal)
###[Pareto](randomkit.html#pareto)
###[Poisson](randomkit.html#poisson)
###[Power](randomkit.html#power)
###[Randint](randomkit.html#randint)
###[Random](randomkit.html#random)
###[Random sample](randomkit.html#random_sample)
###[Rayleigh](randomkit.html#rayleigh)
###[Standard cauchy](randomkit.html#standard_cauchy)
###[Standard exponential](randomkit.html#standard_exponential)
###[Standard gamma](randomkit.html#standard_gamma)
###[Standard normal](randomkit.html#standard_normal)
###[Standard t](randomkit.html#standard_t)
###[Triangular](randomkit.html#triangular)
###[Ulong](randomkit.html#ulong)
###[Uniform](randomkit.html#uniform)
###[Vonmises](randomkit.html#vonmises)
###[Wald](randomkit.html#wald)
###[Weibull](randomkit.html#weibull)
###[Zipf](randomkit.html#zipf)

##Unit Tests

Last but not least, the unit tests are in the folder
[`luasrc/tests`](https://github.com/jucor/torch-randomkit/tree/master/luasrc/tests). You can run them from your local clone of the repostiory with:

```bash
git clone https://www.github.com/jucor/torch-randomkit
find torch-randomkit/luasrc/tests -name "test*lua" -exec torch {} \;
```

Those tests will soone be automatically installed with the package, once I sort out a bit of CMake resistance.

##Direct access to FFI

###randomkit.ffi.*

Functions directly accessible at the top of the `randomkit` table are Lua wrappers to the actual C functions from Randomkit, with extra error checking. If, for any reason, you want to get rid of this error checking and of a possible overhead, the FFI-wrapper functions can be called directly via `randomkit.ffi.myfunction()` instead of `randomkit.myfunction()`.

