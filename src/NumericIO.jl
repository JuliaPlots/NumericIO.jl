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

abstract Formatting

immutable FormattingNative <: Formatting; end
immutable FormattingReal{PREFIX,DISPLAYMODE} <: Formatting
	ndigits::Int
end

#Not part of T<:IO hierarchy... Formatting would ideally be supported
#by print API, but this will do for now...
#TODO: make immutable for efficiency reasons (stack vs heap)?
#      downside: rfmt becomes immutable (must create new object to change rfmt)
type FormattedIO{T<:IO}
	stream::T
	rfmt::Formatting
	#TODO: add other formatting??...
end


#==Constructors
===============================================================================#
#Only support SHORTEST & PRECISION, for now:
function FormattingReal(pfx::Symbol, ndigits::Int)
	dm = ndigits<1? (Base.Grisu.SHORTEST) : (Base.Grisu.PRECISION)
	return FormattingReal{pfx,dm}(ndigits)
end

formatted(io::IO, pfx::Symbol=:ENG; ndigits::Int=0) =
	FormattedIO(io, FormattingReal(pfx, ndigits))


#==High-level API for figuring out formatting
===============================================================================#
#Formatting(io::IO, ::Type) = FormattingNative() #What would be defined for ::IO (for illustration purposes)
Formatting(io::FormattedIO, ::Type) = FormattingNative()
Formatting{T<:Real}(io::FormattedIO, ::Type{T}) = io.rfmt


#==Display formatted numbers
===============================================================================#

#Default (native) formatting on IO:
_print_fmt(io::IO, v, ::FormattingNative) = print(io, v)

#Engineering notation
function _print_fmt{DM}(io::IO, v::AbstractFloat, fmt::FormattingReal{:ENG,DM})
	Base.Grisu._show(io, v, DM, fmt.ndigits, false)
end


#SI notation
function _print_fmt{DM}(io::IO, v::AbstractFloat, fmt::FormattingReal{:SI,DM})
	if isinf(v) || isnan(v)
		return print(io, v)
	end
	len, pt, neg, buffer = Base.Grisu.grisu(v, DM, fmt.ndigits)
	pdigits = pointer(buffer)
	xpnt = pt - 3 #Targeted exponent value (show up to 3 digits above decimal)
	#Compute index of SI:
	idx = clamp(ceil(Int,xpnt/3), 1-_SIPREFIXES_OFFSET, length(_SIPREFIXES)-_SIPREFIXES_OFFSET)
	xpnt = idx * 3 #Back to exponent, rounded off to SI steps
	ptshift = pt-xpnt #shifted decimal point location
	if ptshift < 1 || ptshift > 3 #very small/large numbers (Beyond SI prefixes)
		return Base.Grisu._show(io, v, DM, fmt.ndigits, false) 
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

_print_fmt(io::IO, v::Real, fmt::FormattingReal) =
	_print_fmt(io, convert(AbstractFloat, v), fmt)

#==HACK-ish: Provide base IO-like functionality
(Preferable to have IO support Formatting directly)
===============================================================================#

Base.print(io::FormattedIO, v) = _print_fmt(io.stream, v, Formatting(io, typeof(v)))
function Base.print(io::FormattedIO, xs...)
	for x in xs
		print(io, x)
	end
end
Base.println(io::FormattedIO, xs...) = print(io, xs..., '\n')

#Relay base functionnality:
Base.write(io::FormattedIO, v) = Base.write(io.stream, v)
Base.read(io::FormattedIO, v) = Base.read(io.stream, v)


#==One-off solution to formatting individual values
===============================================================================#
function formatted(v::Real, pfx::Symbol=:ENG; ndigits::Int=0)
	s = IOBuffer()
	fio = FormattedIO(s, FormattingReal(pfx, ndigits))
	print(fio, v)
	d = s.data
	resize!(d, s.size)
	return bytestring(d)
end


export formatted
end #Module NumericIO
