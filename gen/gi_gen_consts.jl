using GI

#to regenerate, execute
#julia gi_gen_consts.jl 2
#julia gi_gen_consts.jl 3

const_expr(name,val) =  :($(Symbol(name)) = $(val))

function enum_decl(enumname,vals)
    body = Expr(:block)
    for (name,val) in vals
        if match(r"^[a-zA-Z_]",string(name)) === nothing
            name = "_$name"
        end
        name = uppercase(string(name))
        push!(body.args, const_expr(name,val) )
    end
    Expr(:toplevel,Expr(:module, false, Symbol(enumname), body))
end

function strip_mask(vals)
    if all( [endswith(string(name),"_mask") for (name,val) in vals] )
        [ (Symbol(string(name)[1:end-5]),val) for (name,val) in vals]
    else
        vals
    end
end

nam(t) = t[1]

function write_gtk_consts(fn)
    body = Expr(:block)
    toplevel = Expr(:toplevel,Expr(:module, true, :GConstants, body))
    exprs = body.args
    exports = Expr(:export)

    glib = GINamespace(:GLib,"2.0")
    for (name,val) in GI.get_consts(glib)
            push!(exprs, const_expr("G_$name",val))
    end
    for (name,vals,isflags) in GI.get_enums(glib)
        name = Symbol("G$name")
        push!(exprs, enum_decl(name,vals))
        push!(exports.args, name)
    end

    gtk = GINamespace(:Gtk,"$version.0")
    gtk_exclude = ["STOCK_", "STYLE_", "PRINT_SETTINGS_"]
    for (name,val) in GI.get_consts(gtk)
        if !any([startswith(string(name),prefix) for prefix in gtk_exclude])
            push!(exprs, const_expr("GTK_$name",val))
        end
    end
    for (name,vals,isflags) in GI.get_enums(gtk)
        name = Symbol("Gtk$name")
        push!(exprs, enum_decl(name,vals))
        push!(exports.args, name)
    end

    gdk = GINamespace(:Gdk)
    #Key names could go into a Dict/submodule or something
    for (name,val) in GI.get_consts(gdk)
        if !startswith(string(name),"KEY_")
            push!(exprs, const_expr("GDK_$name",val))
        end
    end
    for (name,vals,isflags) in GI.get_enums(gdk)
        if isflags
            vals = strip_mask(vals)
        end
        if name == :ModifierType
            push!(vals, (:buttons, 256+512+1024+2048+4096))
        end
        name = Symbol("Gdk$name")
        push!(exprs, enum_decl(name,vals))
        push!(exports.args, name)
    end
    push!(exprs,exports)
    open(fn,"w") do f
        Base.println(f,"quote")
        Base.show_unquoted(f, toplevel)
        println(f)
        Base.println(f,"end")
    end
end

version = (length(ARGS) > 0) ? parse(Int,ARGS[1]) : 3

write_gtk_consts("gconsts$version")
