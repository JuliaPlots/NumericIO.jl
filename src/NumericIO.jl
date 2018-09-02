#NumericIO: Formatting tools
__precompile__(true)

module NumericIO
#-------------------------------------------------------------------------------
#=
Floating-point display modes:
   SHORTEST, FIXED, PRECISION
Notation:
	:SI (..., m, μ, n, ...)
	:ENG (..., XE-3, XE-6, XE-9, ...) => not yet supported
	:SCI (..., XE-3, XE-4, XE-5, ...)
=#

import Printf.@printf


#==Constants
===============================================================================#
#TODO: vector Char instead???
const UTF8_SIPREFIXES = String[
	"y", "z", "a", "f", "p", "n", "μ", "m", "",
	"k", "M", "G", "T", "P", "E", "Z", "Y"
]
const ASCII_SIPREFIXES = String[
	"y", "z", "a", "f", "p", "n", "u", "m", "",
	"k", "M", "G", "T", "P", "E", "Z", "Y"
]

const _SIPREFIXES = ASCII_SIPREFIXES
const _SIPREFIXES_OFFSET = 9

const UTF8_SUPERSCRIPT_NUMERALS = Char['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹']
#const UTF8_SUPERSCRIPT_MINUS = '⁻'
#const UTF8_TIMES_SYMBOL = '×'
const UTF8_MINUS_SYMBOL = '−' #Longer than dash.
#const UTF8_INF_SYMBOL = '∞'
const UTF8_INF_STRING = "∞"
const ASCII_SUPERSCRIPT_NUMERALS = Char['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
#const ASCII_SUPERSCRIPT_MINUS = '-'
#const ASCII_TIMES_SYMBOL = 'x'
#const ASCII_MINUS_SYMBOL = '-'

GRISU_FAILURE_WARNED = false


#==Base types
===============================================================================#

abstract type Charset{T} end

abstract type IOFormatting end
struct IOFormattingNative <: IOFormatting; end

#How to format exponential portion (ex: x10³ / E3 / E+3 / e003 / k / x1000 / ...):
abstract type IOFormattingExp <: IOFormatting end

#Format exponent using numeric values:
struct IOFormattingExpNum <: IOFormattingExp
	basemult::String #(ex: "x10" / "e" / "E")
	showplus::Bool #Show "+" on exponent portion?
	plus::Char
	minus::Char
	numerals::Vector{Char}
end

#Format exponent using SI notation:
struct IOFormattingExpSI <: IOFormattingExp #SI Notation: 5.8p
	prefixes::Vector{String}
	default::IOFormattingExpNum
end 

#TODO: arbitrary base?
mutable struct IOFormattingReal <: IOFormatting
	ndigits::Int #Number of digits to display/maximum digits
	#displayshortest::Bool #TODO ?use ndigits<1?
	decpos::Int #Fixed decimal position (value of exponent)
	decfloating::Bool #Ignores decpos - auto-detects 
	showexp0::Bool #Show exponent when value is 0?
	eng::Bool #Whether to restrict to powers that are multiples of 3 (decfloating=true)
	#engalign::Int Where to align decimal engieering values (decfloating=true)
	minus::Char #Potentially use UTF8 '−': Longer than dash.
	inf::String
	expdisplay::IOFormattingExp
end

#Wrapper for IO object that supports formatting of types.
#Not part of T<:IO hierarchy... IOFormatting would ideally be supported
#by print API, but this will do for now...
#TODO: make immutable for efficiency reasons (stack vs heap)?
#      downside: rfmt becomes immutable (must create new object to change rfmt)
mutable struct FormattedIO{T<:IO}
	stream::T
	rfmt::IOFormattingReal
	#TODO: add other formatting (ex: non-numeric data)??...
end


#==Preset Constants
===============================================================================#
#Format exponent using UTF8 characters - ex: 5.8x10⁻¹²
const UEXPONENT = IOFormattingExpNum(
	"×10", false, '⁺', '⁻', UTF8_SUPERSCRIPT_NUMERALS
)
#Format exponent using ASCII characters - ex: 5.8x10^-12
const AEXPONENT = IOFormattingExpNum(
	"x10^", false, '+', '-', ASCII_SUPERSCRIPT_NUMERALS
)
#Format exponent using (ASCII) "E-notation" - ex: 5.8E-12
const AEXPONENT_E = IOFormattingExpNum(
	"E", false, '+', '-', ASCII_SUPERSCRIPT_NUMERALS
)
const UEXPONENT_SI = IOFormattingExpSI(UTF8_SIPREFIXES, UEXPONENT)
const AEXPONENT_SI = IOFormattingExpSI(ASCII_SIPREFIXES, AEXPONENT_E) #Users probably prefer E-notation


#==Helper Functions
===============================================================================#

#Figure out formatting of a giving type:
#IOFormatting(io::IO, ::Type) = IOFormattingNative() #What would be defined for ::IO (for illustration purposes)
IOFormatting(io::FormattedIO, ::Type) = IOFormattingNative() #Default: use native formatting
IOFormatting(io::FormattedIO, ::Type{T}) where T<:Real = io.rfmt

#Accessors:
#charset(::IOFormattingReal) = ... #TODO: implement

function warn_grisufail()
	global GRISU_FAILURE_WARNED
	if !GRISU_FAILURE_WARNED
		@warn("Use of Grisu system failed.  Number display will be degraded.")
	end
	GRISU_FAILURE_WARNED = true
end

base10exp(v::AbstractFloat) = floor(log10(abs(v)))


#==Constructors
===============================================================================#

IOFormattingReal(expdisplay::IOFormattingExp; ndigits=3,
		decpos=1, decfloating=true, showexp0=true, eng=true, minus='-', inf="Inf") =
	IOFormattingReal(ndigits, decpos, decfloating, showexp0, eng, minus, inf, expdisplay)

function IOFormattingReal(notation::Symbol, ::Type{Charset{:UTF8}}; ndigits::Int=0,
		decpos::Int=1, decfloating::Bool=true, showexp0::Bool=true,
		minus::Char=UTF8_MINUS_SYMBOL, inf::String=UTF8_INF_STRING)
	local expdisplay, eng
	if :SCI == notation
		expdisplay=UEXPONENT; eng=false;
	elseif :ENG == notation
		expdisplay=UEXPONENT; eng=true;
	elseif :SI == notation
		expdisplay=UEXPONENT_SI; eng=true;
	else
		error("Unrecognized notation: $notation.")
	end
	return IOFormattingReal(expdisplay, ndigits=ndigits, decpos=decpos, decfloating=decfloating,
		showexp0=showexp0, eng=eng, minus=minus, inf=inf
	)
end

function IOFormattingReal(notation::Symbol, ::Type{Charset{:ASCII}}; ndigits::Int=0,
		decpos::Int=1, decfloating::Bool=true, showexp0::Bool=true,
		minus::Char='-', inf::String="Inf")
	local expdisplay, eng
	if :SCI == notation
		expdisplay=AEXPONENT_E; eng=false;
	elseif :ENG == notation
		expdisplay=AEXPONENT_E; eng=true;
	elseif :SI == notation
		expdisplay=AEXPONENT_SI; eng=true;
	else
		error("Unrecognized notation: $notation.")
	end
	return IOFormattingReal(expdisplay, ndigits=ndigits, decpos=decpos, decfloating=decfloating,
		showexp0=showexp0, eng=eng, minus=minus, inf=inf
	)
end


#==Main Algorithms
===============================================================================#

#Print everything before the exponential:
function print_formatted_mantgrisu(io::IO, val::AbstractFloat, fmt::IOFormattingReal)
	if val < 0
		write(io, fmt.minus)
	elseif isnan(val)
		write(io, "NaN")
		return 0
#TODO: show plus?
	end
	if isinf(val)
		write(io, fmt.inf)
		return 0
	end

	#Aliases:
	decfloating = fmt.decfloating #WANTCONST
	decpos = fmt.decpos #Only valid if !decfloating
	ndigits = fmt.ndigits
	shortest = ndigits < 1 #WANTCONST
	prec = shortest ? Base.Grisu.SHORTEST : Base.Grisu.PRECISION #WANTCONST
	local pt_shifted

	len, pt, neg = Base.Grisu.grisu(val, prec, ndigits)
	buffer = Base.Grisu.DIGITS #Point to GRISU output buffer

	#NOTE: pt is decimal point location in array (5x10EY has pt=Y+1)
	if shortest; ndigits = len; end

	if decfloating
		decpos = pt-1
		if fmt.eng
			engalign = 3 #WANTCONST: Show up to 3 digits above decimal before moving to the next 10^3 step

			#Targeted decimal position (show up to engalign digits above decimal):
			decpos -= engalign-3
			decpos = floor(Int, decpos/3)*3
		end

		pt_shifted = pt - decpos
	elseif 0 == val #&& !decfloating
		pt_shifted = 1 #0*anything=0.  Just make output look good.
	else #!decfloating
		pt_shifted = pt - decpos

		if !shortest #Recompute ndgits & buffer.
			#ndigits corresponds to "displayed" digits... not # of significant digits:
			if pt_shifted < 2 #Some digits had to be clipped
#TODO: Also don't have to recompute if "len" was so short that no rounding is necessary.
				ndigits_disp = max(0, ndigits+pt_shifted-1)
				#Recalculate buffer for new ndigits (avoid roundoff errors):
				#TODO: Try to avoid re-calculation???
				len, pt, neg = Base.Grisu.grisu(val, prec, ndigits_disp)
				buffer = Base.Grisu.DIGITS #Point to GRISU output buffer
			end
			pt -= decpos #shift decimal point
		end
	end

	grisuleft = len
	wholeleft = max(0, pt_shifted)
	fracleft = ndigits-max(1, wholeleft)
	expleft = decpos
	pdigits = pointer(buffer)

	if wholeleft < 1
		write(io, "0")
	else
		nchars = min(grisuleft, wholeleft)
		unsafe_write(io, pdigits, nchars)
		pdigits += nchars
		wholeleft -= nchars
		grisuleft -= nchars

		for i in 1:wholeleft
			write(io, "0")
		end
	end

	if fracleft < 1
		return expleft
	end

	write(io, ".") #TODO: Internationalize: ex: French uses ",".

	leadingzeros = decfloating ? 0 : max(0, -pt)
	nzeros = min(leadingzeros, fracleft)
	for i in 1:nzeros
		write(io, "0")
	end
	fracleft -= nzeros

	nchars = min(grisuleft, fracleft)
	unsafe_write(io, pdigits, nchars)
	fracleft -= nchars

	for i in 1:fracleft
		write(io, "0")
	end

	return expleft
end

#Display mantissa - using failsafe in case GRISU interface changes.
function print_formatted_mant(io::IO, val::AbstractFloat, fmt::IOFormattingReal)
	try
#		throw(:TESTME) #TODO
		return print_formatted_mantgrisu(io, val, fmt)
	catch e #In case GRISU API changes:
#rethrow(e)
		warn_grisufail()
		exp = base10exp(val)
		if !isfinite(exp)
			exp = 0
		else
			exp = round(Int, exp) #Needed in Int form
			exp += fmt.decpos
		end
		val /= 10.0^exp
		@printf(io, "%.3f", val) #Display something
		return exp
	end
end

#Exponents displayed using numeric notation:
function print_formatted_exp(io::IO, fmt::IOFormattingExpNum, exp::Int)
	write(io, fmt.basemult)
	exp_str = "$exp"

	c = exp_str[1]
	if '-' == c
		write(io, fmt.minus)
	elseif fmt.showplus
		write(io, fmt.plus)
	end

	for c in exp_str
		if isnumeric(c)
			idx = c - ('0' - 1)
			write(io, fmt.numerals[idx])
		end
	end
	nothing
end

#Exponents displayed using SI notation:
function print_formatted_exp(io::IO, fmt::IOFormattingExpSI, exp::Int)
	fidx = exp/3
	idx = round(Int, fidx)
	if idx != fidx #Is isinteger() safe in this context?
		#TODO: throw error instead?... or maybe print x10n or x100n, ... ?
		#Just print using "numeric formatting" fallback for the moment:
		return print_formatted_exp(io, fmt.default, exp)
	end

	idx += _SIPREFIXES_OFFSET
	if idx > 0 && idx <= length(fmt.prefixes)
		print(io, fmt.prefixes[idx])
	else #Fall back to using "numeric formatting" on exponent:
		print_formatted_exp(io, fmt.default, exp)
	end
	return nothing
end

function print_formatted_exp(io::IO, fmt::IOFormattingReal)
	@assert(!fmt.decfloating, "Cannot determine exponent when decimal is floating.")
	exp = fmt.decpos #Just showing exponential portion...
	if fmt.showexp0 || exp != 0
		print_formatted_exp(io, fmt.expdisplay, exp)
	end
end


#==Intermediate print_formatted/string_formatted interfaces
===============================================================================#

#Default (native) formatting on IO:
print_formatted(io::IO, v, ::IOFormattingNative) = print(io, v)

function print_formatted(io::IO, val::AbstractFloat, fmt::IOFormattingReal, showexp::Bool)
	exp = print_formatted_mant(io, val, fmt)
	if isfinite(val) && showexp && (fmt.showexp0 || exp != 0)
		print_formatted_exp(io, fmt.expdisplay, exp)
	end
end

print_formatted(io::IO, v::Real, fmt::IOFormattingReal; showexp::Bool=true) =
	print_formatted(io, convert(AbstractFloat, v), fmt, showexp)

#One-off solution to formatting individual values:
function string_formatted(v::Real, fmt::IOFormattingReal; showexp::Bool=true)
	s = IOBuffer()
	print_formatted(s, v, fmt, showexp=showexp)
	d = s.data
	resize!(d, s.size)
	return String(d)
end


#==HACK-ish: Provide base IO-like functionality
(Preferable to have IO support IOFormatting directly)
===============================================================================#

Base.print(io::FormattedIO, v) = print_formatted(io.stream, v, IOFormatting(io, typeof(v)))
function Base.print(io::FormattedIO, xs...)
	for x in xs
		print(io, x)
	end
end
Base.println(io::FormattedIO, xs...) = print(io, xs..., '\n')

#Relay base functionnality:
Base.write(io::FormattedIO, v) = Base.write(io.stream, v)
Base.read(io::FormattedIO, v) = Base.read(io.stream, v)


#==User-Level "formatted" interface
===============================================================================#
formatted(io::IO, fmt::IOFormattingReal) = FormattedIO(io, fmt)

#NOTE: No type for characterset... use string type instead.
#TODO: Add ::Type{Real} to signature??
formatted(io::IO, notation::Symbol=:SCI; ndigits::Int=0, charset::Symbol=:UTF8) =
	FormattedIO(io, IOFormattingReal(notation, Charset{charset}, ndigits=ndigits))

#One-off solution to formatting individual values:
formatted(v::Real, fmt::IOFormattingReal; showexp::Bool=true) =
	string_formatted(v, fmt, showexp=showexp)
formatted(v::Real, notation::Symbol=:SCI; ndigits::Int=0, charset::Symbol=:UTF8,
		showexp::Bool=true) =
	string_formatted(v, IOFormattingReal(notation, Charset{charset}, ndigits=ndigits), showexp=showexp)


#==Exported interface (keep mimimal to avoid collisions).
===============================================================================#
export formatted

end #Module NumericIO
