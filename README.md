# NumericIO.jl

## Description

Improves output format control for numeric data:

 - Includes facilities to display values using SI prefixes (`Y`, `Z`, `E`, `P`, `T`, `G`, `M`, `k`, `m`, &mu;, `n`, `p`, `f`, `a`, `z`, `y`)
 - Makes it easy to control the number of significant digits to display.

## Usage

NumericIO.jl tries to provide the convenience of c++ `ios_base` configurability (ex: setting `ios_base::precision`) *without* modifying the output format of the base streaming object. Instead, NumericIO.jl uses the `FormattedIO` wrapper object to print data with the desired output format.

To obtain a string representation of a `Real` value using SI prefixes, one can use the `formatted` function:

	formatted(3.14159e-9, :SI, ndigits=3) # => "3.14n"

Similarly, the string representation of a `Real` value using engineering notation is obtained as follows:

	Formatted(3.14159e-9, :ENG, ndigits=3) # => "3.14e-9"

It might also be useful to create a convenience formatting function:

	SI(x) = formatted(x, :SI, ndigits=4)
	println(SI(3.14159e-9)) # => 3.142n
	println(SI(2.71828e12)) # => 2.718T

To print out multiple values, it is preferable to directly create a FormattedIO wrapper object:

	fio = formatted(STDOUT, :SI, ndigits=4) # => FormattedIO
	println(fio, 3.14159e-9) # => 3.142n
	println(fio, 2.71828e12) # => 2.718T
	...

## Known Limitations

### Compatibility

Extensive compatibility testing of NumericIO.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-0.4.2
