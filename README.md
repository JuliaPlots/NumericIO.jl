# NumericIO.jl

## Description

Provides improved formatted representations of numeric values:

 - Includes facilities to display values using SI prefixes (`Y`, `Z`, `E`, `P`, `T`, `G`, `M`, `k`, `m`, &mu;, `n`, `p`, `f`, `a`, `z`, `y`)
 - Makes it easy to control the number of significant digits to display.

## Usage

To obtain a string representation of a `Real` value using SI prefixes, create a `Formatted` object, and `print`, or convert to string:

	fval = Formatted(3.14159e-9, :SI, ndigits=3)
	println(fval)
	fstr = string(fval)

Similarly, the string representation of a `Real` value using engineering notation is obtained as follows:

	fval = Formatted(3.14159e-9, :ENG, ndigits=3)
	println(fval)
	fstr = string(fval)

To format multiple values, simply create a temporary function:

	SI(x) = Formatted(x, :SI, ndigits=4)
	println(SI(3.14159e-9))
	println(SI(2.71828e12))
	...

## Known Limitations

### Compatibility

Extensive compatibility testing of NumericIO.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-0.4.2
