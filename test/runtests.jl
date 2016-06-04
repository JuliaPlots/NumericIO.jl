using NumericIO
using Base.Test


#==Generate test code
===============================================================================#
if false
tf = open("testgen.jl", "w")
_ndigits=5
println(tf, "SI(v) = formatted(v, :SI, ndigits=$ndigits)")

for _exp in -30:30
	v = e*10^Float64(_exp)
	vstr = formatted(v, :SI, ndigits=_ndigits)
	println(tf, "@test string(SI($v)) == \"$vstr\"")
end

for _ndigits in 0:5
	println(tf, "SI(v) = formatted(v, :SI, ndigits=$_ndigits)")

	for _exp in 6:9
		v = e*10^Float64(_exp)
		vstr = formatted(v, :SI, ndigits=_ndigits)
		println(tf, "@test string(SI($v)) == \"$vstr\"")
	end
end

_exp = 6
v = e*10^Float64(_exp)
for _ndigits in 0:5
	println(tf, "dflt(v) = formatted(v, ndigits=$_ndigits)")
	vstr = formatted(v, ndigits=_ndigits)
	println(tf, "@test string(dflt($v)) == \"$vstr\"")
end
close(tf)
end


#==Exponent tests: Formatting with SI prefixes
===============================================================================#
SI(v) = formatted(v, :SI, ndigits=5)
@test string(SI(-2.7182818284590455e-30)) == "-2.7183e-30" #Negative
@test string(SI(-2.7182818284590453e-24)) == "-2.7183y"
@test string(SI(-2.718281828459045e30)) == "-2.7183e30"

@test string(SI(2.7182818284590455e-30)) == "2.7183e-30"
@test string(SI(2.7182818284590454e-29)) == "2.7183e-29"
@test string(SI(2.718281828459045e-28)) == "2.7183e-28"
@test string(SI(2.7182818284590452e-27)) == "2.7183e-27"
@test string(SI(2.718281828459045e-26)) == "2.7183e-26"
@test string(SI(2.718281828459045e-25)) == "2.7183e-25"
@test string(SI(2.7182818284590453e-24)) == "2.7183y"
@test string(SI(2.718281828459045e-23)) == "27.183y"
@test string(SI(2.718281828459045e-22)) == "271.83y"
@test string(SI(2.7182818284590455e-21)) == "2.7183z"
@test string(SI(2.7182818284590455e-20)) == "27.183z"
@test string(SI(2.718281828459045e-19)) == "271.83z"
@test string(SI(2.7182818284590453e-18)) == "2.7183a"
@test string(SI(2.718281828459045e-17)) == "27.183a"
@test string(SI(2.718281828459045e-16)) == "271.83a"
@test string(SI(2.718281828459045e-15)) == "2.7183f"
@test string(SI(2.7182818284590452e-14)) == "27.183f"
@test string(SI(2.718281828459045e-13)) == "271.83f"
@test string(SI(2.718281828459045e-12)) == "2.7183p"
@test string(SI(2.7182818284590454e-11)) == "27.183p"
@test string(SI(2.718281828459045e-10)) == "271.83p"
@test string(SI(2.718281828459045e-9)) == "2.7183n"
@test string(SI(2.718281828459045e-8)) == "27.183n"
@test string(SI(2.718281828459045e-7)) == "271.83n"
@test string(SI(2.718281828459045e-6)) == "2.7183u"
@test string(SI(2.718281828459045e-5)) == "27.183u"
@test string(SI(0.00027182818284590454)) == "271.83u"
@test string(SI(0.002718281828459045)) == "2.7183m"
@test string(SI(0.027182818284590453)) == "27.183m"
@test string(SI(0.27182818284590454)) == "271.83m"
@test string(SI(2.718281828459045)) == "2.7183"
@test string(SI(27.18281828459045)) == "27.183"
@test string(SI(271.8281828459045)) == "271.83"
@test string(SI(2718.2818284590453)) == "2.7183k"
@test string(SI(27182.818284590452)) == "27.183k"
@test string(SI(271828.1828459045)) == "271.83k"
@test string(SI(2.718281828459045e6)) == "2.7183M"
@test string(SI(2.718281828459045e7)) == "27.183M"
@test string(SI(2.718281828459045e8)) == "271.83M"
@test string(SI(2.718281828459045e9)) == "2.7183G"
@test string(SI(2.718281828459045e10)) == "27.183G"
@test string(SI(2.718281828459045e11)) == "271.83G"
@test string(SI(2.718281828459045e12)) == "2.7183T"
@test string(SI(2.718281828459045e13)) == "27.183T"
@test string(SI(2.718281828459045e14)) == "271.83T"
@test string(SI(2.718281828459045e15)) == "2.7183P"
@test string(SI(2.7182818284590452e16)) == "27.183P"
@test string(SI(2.718281828459045e17)) == "271.83P"
@test string(SI(2.718281828459045e18)) == "2.7183E"
@test string(SI(2.7182818284590453e19)) == "27.183E"
@test string(SI(2.7182818284590452e20)) == "271.83E"
@test string(SI(2.718281828459045e21)) == "2.7183Z"
@test string(SI(2.718281828459045e22)) == "27.183Z"
@test string(SI(2.7182818284590448e23)) == "271.83Z"
@test string(SI(2.718281828459045e24)) == "2.7183Y"
@test string(SI(2.7182818284590455e25)) == "27.183Y"
@test string(SI(2.7182818284590452e26)) == "271.83Y"
@test string(SI(2.7182818284590453e27)) == "2.7183e27"
@test string(SI(2.718281828459045e28)) == "2.7183e28"
@test string(SI(2.7182818284590454e29)) == "2.7183e29"
@test string(SI(2.718281828459045e30)) == "2.7183e30"


#==Number of digits: Formatting with SI prefixes
===============================================================================#
SI(v) = formatted(v, :SI, ndigits=0)
@test string(SI(2.718281828459045e6)) == "2.718281828459045M"
@test string(SI(2.718281828459045e7)) == "27.18281828459045M"
@test string(SI(2.718281828459045e8)) == "271.8281828459045M"
@test string(SI(2.718281828459045e9)) == "2.718281828459045G"
SI(v) = formatted(v, :SI, ndigits=1)
@test string(SI(2.718281828459045e6)) == "3M"
@test string(SI(2.718281828459045e7)) == "30M"
@test string(SI(2.718281828459045e8)) == "300M"
@test string(SI(2.718281828459045e9)) == "3G"
SI(v) = formatted(v, :SI, ndigits=2)
@test string(SI(2.718281828459045e6)) == "2.7M"
@test string(SI(2.718281828459045e7)) == "27M"
@test string(SI(2.718281828459045e8)) == "270M"
@test string(SI(2.718281828459045e9)) == "2.7G"
SI(v) = formatted(v, :SI, ndigits=3)
@test string(SI(2.718281828459045e6)) == "2.72M"
@test string(SI(2.718281828459045e7)) == "27.2M"
@test string(SI(2.718281828459045e8)) == "272M"
@test string(SI(2.718281828459045e9)) == "2.72G"
SI(v) = formatted(v, :SI, ndigits=4)
@test string(SI(2.718281828459045e6)) == "2.718M"
@test string(SI(2.718281828459045e7)) == "27.18M"
@test string(SI(2.718281828459045e8)) == "271.8M"
@test string(SI(2.718281828459045e9)) == "2.718G"
SI(v) = formatted(v, :SI, ndigits=5)
@test string(SI(2.718281828459045e6)) == "2.7183M"
@test string(SI(2.718281828459045e7)) == "27.183M"
@test string(SI(2.718281828459045e8)) == "271.83M"
@test string(SI(2.718281828459045e9)) == "2.7183G"


#==Number of digits: Formatting with scientific notation
===============================================================================#
dflt(v) = formatted(v, ndigits=0)
@test string(dflt(2.718281828459045e6)) == "2.718281828459045e6"
dflt(v) = formatted(v, ndigits=1)
@test string(dflt(2.718281828459045e6)) == "3.0e6"
dflt(v) = formatted(v, ndigits=2)
@test string(dflt(2.718281828459045e6)) == "2.7e6"
dflt(v) = formatted(v, ndigits=3)
@test string(dflt(2.718281828459045e6)) == "2.72e6"
dflt(v) = formatted(v, ndigits=4)
@test string(dflt(2.718281828459045e6)) == "2.718e6"
dflt(v) = formatted(v, ndigits=5)
@test string(dflt(2.718281828459045e6)) == "2.7183e6"


#==Integer values: Formatting
===============================================================================#
@test string(formatted(2_718_281_828, :SI, ndigits=3)) == "2.72G"
@test string(formatted(2_718_281_828, :SCI, ndigits=3)) == "2.72e9"

:Tests_Complete
