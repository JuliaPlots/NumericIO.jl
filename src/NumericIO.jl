#NumericIO: Formatting tools

module NumericIO
#-------------------------------------------------------------------------------
#=
Floating-point display modes:
   SHORTEST, FIXED, PRECISION
Prefixes:
	:SI (m, μ, n, ...), :ENG (XE-10)
=#


#==Constants
===============================================================================#

#Don't use μ ... in case some algorithms don't deal well with UTF8:
const _SIPREFIXES = ASCIIString[
	"y", "z", "a", "f", "p", "n", "u", "m", "",
	"k", "M", "G", "T", "P", "E", "Z", "Y"
]
const _SIPREFIXES_OFFSET = 9


#==Base types
===============================================================================#

#Describes how to format floating point values:
immutable Formatted{PREFIX,DISPLAYMODE,T<:Real}
	v::T
	ndigits::Int
end


#==Constructors
===============================================================================#
#Only support SHORTEST & PRECISION, for now:
function Formatted{T<:Real}(v::T, pfx::Symbol=:ENG; ndigits::Int=0)
	dm = 0==ndigits? (Base.Grisu.SHORTEST) : (Base.Grisu.PRECISION)
	return Formatted{pfx,dm,T}(v, ndigits)
end


#==Display formatted numbers
===============================================================================#

#Engineering notation
Base.print{DM,T<:AbstractFloat}(io::IO, v::Formatted{:ENG,DM,T}) =
	Base.Grisu._show(io, v.v, DM, v.ndigits, false)

#SI notation
function Base.print{DM,T<:AbstractFloat}(io::IO, v::Formatted{:SI,DM,T})
	if isinf(v.v) || isnan(v.v)
		return print(io, v.v)
	end
	len, pt, neg, buffer = Base.Grisu.grisu(v.v, DM, v.ndigits)
	pdigits = pointer(buffer)
	xpnt = pt - 3 #Targeted exponent value (show up to 3 digits above decimal)
	#Compute index of SI:
	idx = clamp(ceil(Int,xpnt/3), 1-_SIPREFIXES_OFFSET, length(_SIPREFIXES)-_SIPREFIXES_OFFSET)
	xpnt = idx * 3 #Back to exponent, rounded off to SI steps
	ptshift = pt-xpnt #shifted decimal point location
	if ptshift < 1 || ptshift > 3 #very small/large numbers (Beyond SI prefixes)
		return Base.Grisu._show(io, v.v, DM, v.ndigits, false) 
	end
	nchars1 = min(len, ptshift) #Before decimal
		write(io, pdigits, nchars1)
	nzeros = ptshift-len
	for i in 1:nzeros
		write(io, "0")
	end
	nchars2 = -nzeros
	if nchars2 > 0
		write(io, ".")
		write(io, pdigits+nchars1, nchars2)
	end
	idx += _SIPREFIXES_OFFSET
	print(io, _SIPREFIXES[idx])
end

function Base.print{PFX,DM,T<:Real}(io::IO, v::Formatted{PFX,DM,T})
	v2 = convert(AbstractFloat, v.v)
	return Base.print(io, Formatted{PFX,DM,typeof(v2)}(v2, v.ndigits))
end

export Formatted
end #Module NumericIO
