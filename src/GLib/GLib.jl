module GLib

if isdefined(Base, :Experimental) && isdefined(Base.Experimental, Symbol("@optlevel"))
    @eval Base.Experimental.@optlevel 1
end

# Import `libgobject` and whatnot
using Glib_jll

if false
function include(x)
    println("including $x")
    @time Base.include(x)
end
end

import Base: convert, copy, show, size, length, getindex, setindex!, get,
             iterate, eltype, isempty, ndims, stride, strides, popfirst!,
             empty!, append!, reverse!, pushfirst!, pop!, push!, splice!,
             sigatomic_begin, sigatomic_end, Sys.WORD_SIZE, unsafe_convert, getproperty,
             getindex, setindex!

using Libdl

export GInterface, GType, GObject, GBoxed, @Gtype, @Gabstract, @Giface
export GEnum, GError, GValue, gvalue, make_gvalue, @make_gvalue, g_type
export GList, glist_iter, _GSList, _GList, gobject_ref, gobject_move_ref
export signal_connect, signal_emit, signal_handler_disconnect
export signal_handler_block, signal_handler_unblock
export g_timeout_add, g_idle_add, @idle_add
export set_gtk_property!, get_gtk_property
export GConnectFlags
export @sigatom, cfunction_


cfunction_(@nospecialize(f), r, a::Tuple) = cfunction_(f, r, Tuple{a...})

@generated function cfunction_(f, R::Type{rt}, A::Type{at}) where {rt, at<:Tuple}
    quote
        @cfunction($(Expr(:$,:f)), $rt, ($(at.parameters...),))
    end
end

# local function, handles Symbol and makes UTF8-strings easier
const  AbstractStringLike = Union{AbstractString, Symbol}
bytestring(s) = String(s)
bytestring(s::Symbol) = s
bytestring(s::Ptr{UInt8}) = unsafe_string(s)
# bytestring(s::Ptr{UInt8}, own::Bool=false) = unsafe_string(s)

g_malloc(s::Integer) = ccall((:g_malloc, libglib), Ptr{Nothing}, (Csize_t,), s)
g_free(p::Ptr) = ccall((:g_free, libglib), Nothing, (Ptr{Nothing},), p)

ccall((:g_type_init, libgobject), Nothing, ())

include("MutableTypes.jl")
using .MutableTypes
include("glist.jl")
include("gtype.jl")
include("gvalues.jl")
include("gerror.jl")
include("signals.jl")

export @g_type_delegate
macro g_type_delegate(eq)
    @assert isa(eq, Expr) && eq.head == :(=) && length(eq.args) == 2
    new = eq.args[1]
    real = eq.args[2]
    newleaf = esc(Symbol(string(new, __module__.suffix)))
    realleaf = esc(Symbol(string(real, __module__.suffix)))
    new = esc(new)
    macroreal = QuoteNode(Symbol(string('@', real)))
    quote
        $newleaf = $realleaf
        macro $new(args...)
            Expr(:macrocall, $macroreal, map(esc, args)...)
        end
    end
end

if Base.VERSION >= v"1.4.2"
    precompile(Tuple{typeof(addref),Any})   # time: 0.003988418
    # precompile(Tuple{typeof(gc_ref),Any})   # time: 0.002649791
end

end
