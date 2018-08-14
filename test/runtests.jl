using NumericIO
using Test


#==Generate test code
===============================================================================#
function _gentestcode()
	tf = open("testgen.jl", "w")
	_ndigits=5
	println(tf, "SI(v) = formatted(v, :SI, ndigits=$_ndigits)")

	for _exp in -30:30
		v = e*10^Float64(_exp)
		vstr = formatted(v, :SI, ndigits=_ndigits)
		println(tf, "@test SI($v) == \"$vstr\"")
	end

	for _ndigits in 0:5
		println(tf, "SI(v) = formatted(v, :SI, ndigits=$_ndigits)")

		for _exp in 6:9
			v = e*10^Float64(_exp)
			vstr = formatted(v, :SI, ndigits=_ndigits)
			println(tf, "@test SI($v) == \"$vstr\"")
		end
	end

	_exp = 6
	v = e*10^Float64(_exp)
	for _ndigits in 0:5
		println(tf, "dflt(v) = formatted(v, ndigits=$_ndigits)")
		vstr = formatted(v, ndigits=_ndigits)
		println(tf, "@test dflt($v) == \"$vstr\"")
	end
	close(tf)
end
#_gentestcode()


#==Helper functions
===============================================================================#
newscope(fn::Function) = (fn()) #Allow re-definition of SI(v) / dflt(v)


#==Exponent tests: Formatting with SI prefixes
===============================================================================#
newscope() do
SI(v) = formatted(v, :SI, ndigits=5)
@test SI(-2.7182818284590455e-30) == "−2.7183×10⁻³⁰" #Negative
@test SI(-2.7182818284590453e-24) == "−2.7183y"
@test SI(-2.718281828459045e30) == "−2.7183×10³⁰"

@test SI(2.7182818284590455e-30) == "2.7183×10⁻³⁰"
@test SI(2.7182818284590454e-29) == "27.183×10⁻³⁰"
@test SI(2.718281828459045e-28) == "271.83×10⁻³⁰"
@test SI(2.7182818284590452e-27) == "2.7183×10⁻²⁷"
@test SI(2.718281828459045e-26) == "27.183×10⁻²⁷"
@test SI(2.718281828459045e-25) == "271.83×10⁻²⁷"
@test SI(2.7182818284590453e-24) == "2.7183y"
@test SI(2.718281828459045e-23) == "27.183y"
@test SI(2.718281828459045e-22) == "271.83y"
@test SI(2.7182818284590455e-21) == "2.7183z"
@test SI(2.7182818284590455e-20) == "27.183z"
@test SI(2.718281828459045e-19) == "271.83z"
@test SI(2.7182818284590453e-18) == "2.7183a"
@test SI(2.718281828459045e-17) == "27.183a"
@test SI(2.718281828459045e-16) == "271.83a"
@test SI(2.718281828459045e-15) == "2.7183f"
@test SI(2.7182818284590452e-14) == "27.183f"
@test SI(2.718281828459045e-13) == "271.83f"
@test SI(2.718281828459045e-12) == "2.7183p"
@test SI(2.7182818284590454e-11) == "27.183p"
@test SI(2.718281828459045e-10) == "271.83p"
@test SI(2.718281828459045e-9) == "2.7183n"
@test SI(2.718281828459045e-8) == "27.183n"
@test SI(2.718281828459045e-7) == "271.83n"
@test SI(2.718281828459045e-6) == "2.7183μ"
@test SI(2.718281828459045e-5) == "27.183μ"
@test SI(0.00027182818284590454) == "271.83μ"
@test SI(0.002718281828459045) == "2.7183m"
@test SI(0.027182818284590453) == "27.183m"
@test SI(0.27182818284590454) == "271.83m"
@test SI(2.718281828459045) == "2.7183"
@test SI(27.18281828459045) == "27.183"
@test SI(271.8281828459045) == "271.83"
@test SI(2718.2818284590453) == "2.7183k"
@test SI(27182.818284590452) == "27.183k"
@test SI(271828.1828459045) == "271.83k"
@test SI(2.718281828459045e6) == "2.7183M"
@test SI(2.718281828459045e7) == "27.183M"
@test SI(2.718281828459045e8) == "271.83M"
@test SI(2.718281828459045e9) == "2.7183G"
@test SI(2.718281828459045e10) == "27.183G"
@test SI(2.718281828459045e11) == "271.83G"
@test SI(2.718281828459045e12) == "2.7183T"
@test SI(2.718281828459045e13) == "27.183T"
@test SI(2.718281828459045e14) == "271.83T"
@test SI(2.718281828459045e15) == "2.7183P"
@test SI(2.7182818284590452e16) == "27.183P"
@test SI(2.718281828459045e17) == "271.83P"
@test SI(2.718281828459045e18) == "2.7183E"
@test SI(2.7182818284590453e19) == "27.183E"
@test SI(2.7182818284590452e20) == "271.83E"
@test SI(2.718281828459045e21) == "2.7183Z"
@test SI(2.718281828459045e22) == "27.183Z"
@test SI(2.7182818284590448e23) == "271.83Z"
@test SI(2.718281828459045e24) == "2.7183Y"
@test SI(2.7182818284590455e25) == "27.183Y"
@test SI(2.7182818284590452e26) == "271.83Y"
@test SI(2.7182818284590453e27) == "2.7183×10²⁷"
@test SI(2.718281828459045e28) == "27.183×10²⁷"
@test SI(2.7182818284590454e29) == "271.83×10²⁷"
@test SI(2.718281828459045e30) == "2.7183×10³⁰"
end


#==Number of digits: Formatting with SI prefixes
===============================================================================#
newscope() do
SI(v) = formatted(v, :SI, ndigits=0)
@test SI(2.718281828459045e6) == "2.718281828459045M"
@test SI(2.718281828459045e7) == "27.18281828459045M"
@test SI(2.718281828459045e8) == "271.8281828459045M"
@test SI(2.718281828459045e9) == "2.718281828459045G"
end
newscope() do
SI(v) = formatted(v, :SI, ndigits=1)
@test SI(2.718281828459045e6) == "3M"
@test SI(2.718281828459045e7) == "30M"
@test SI(2.718281828459045e8) == "300M"
@test SI(2.718281828459045e9) == "3G"
end
newscope() do
SI(v) = formatted(v, :SI, ndigits=2)
@test SI(2.718281828459045e6) == "2.7M"
@test SI(2.718281828459045e7) == "27M"
@test SI(2.718281828459045e8) == "270M"
@test SI(2.718281828459045e9) == "2.7G"
end
newscope() do
SI(v) = formatted(v, :SI, ndigits=3)
@test SI(2.718281828459045e6) == "2.72M"
@test SI(2.718281828459045e7) == "27.2M"
@test SI(2.718281828459045e8) == "272M"
@test SI(2.718281828459045e9) == "2.72G"
end
newscope() do
SI(v) = formatted(v, :SI, ndigits=4)
@test SI(2.718281828459045e6) == "2.718M"
@test SI(2.718281828459045e7) == "27.18M"
@test SI(2.718281828459045e8) == "271.8M"
@test SI(2.718281828459045e9) == "2.718G"
end
newscope() do
SI(v) = formatted(v, :SI, ndigits=5)
@test SI(2.718281828459045e6) == "2.7183M"
@test SI(2.718281828459045e7) == "27.183M"
@test SI(2.718281828459045e8) == "271.83M"
@test SI(2.718281828459045e9) == "2.7183G"
end


#==Number of digits: Formatting with scientific notation
===============================================================================#
newscope() do
dflt(v) = formatted(v, ndigits=0)
@test dflt(2.718281828459045e6) == "2.718281828459045×10⁶"
end
newscope() do
dflt(v) = formatted(v, ndigits=1)
@test dflt(2.718281828459045e6) == "3×10⁶"
end
newscope() do
dflt(v) = formatted(v, ndigits=2)
@test dflt(2.718281828459045e6) == "2.7×10⁶"
end
newscope() do
dflt(v) = formatted(v, ndigits=3)
@test dflt(2.718281828459045e6) == "2.72×10⁶"
end
newscope() do
dflt(v) = formatted(v, ndigits=4)
@test dflt(2.718281828459045e6) == "2.718×10⁶"
end
newscope() do
dflt(v) = formatted(v, ndigits=5)
@test dflt(2.718281828459045e6) == "2.7183×10⁶"
end


#==Integer values: Formatting
===============================================================================#
@test formatted(27_182_818_284, :SI, ndigits=3) == "27.2G"
@test formatted(27_182_818_284, :ENG, ndigits=3) == "27.2×10⁹"
@test formatted(27_182_818_284, :SCI, ndigits=3) == "2.72×10¹⁰"
@test formatted(27_182_818_284, :SCI, ndigits=3, charset=:ASCII) == "2.72E10"


#==Fixed ndigits, fixed decpos
===============================================================================#
#Use lower-level structures for fixed decimal position:
fmt = NumericIO.IOFormattingReal(NumericIO.UEXPONENT_SI,
	ndigits=4, decpos=9, decfloating=false, eng=true,
	minus=NumericIO.UTF8_MINUS_SYMBOL, inf=NumericIO.UTF8_INF_STRING
)
newscope() do
SI(v) = formatted(v, fmt)
@test SI(2.718281828459045e5) == "0.000G"
@test SI(2.718281828459045e6) == "0.003G"
@test SI(2.718281828459045e7) == "0.027G"
@test SI(2.718281828459045e8) == "0.272G"
@test SI(2.718281828459045e9) == "2.718G"
@test SI(2.718281828459045e10) == "27.18G"
@test SI(2.718281828459045e11) == "271.8G"
@test SI(2.718281828459045e12) == "2718G"
@test SI(2.718281828459045e13) == "27180G"
end

:Tests_Complete
