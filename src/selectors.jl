#https://developer.gnome.org/gtk2/stable/SelectorWidgets.html

#GtkColorButton — A button to launch a color selection dialog
#GtkColorSelectionDialog — A standard dialog box for selecting a color
#GtkColorSelection — A widget used to select a color
#GtkHSV — A 'color wheel' widget
#GtkFileChooser — File chooser interface used by GtkFileChooserWidget and GtkFileChooserDialog
#GtkFileChooserButton — A button to launch a file selection dialog
#GtkFileChooserNative — A native file chooser dialog, suitable for “File/Open” or “File/Save” commands
#GtkFileChooserDialog — A file chooser dialog, suitable for "File/Open" or "File/Save" commands
#GtkFileChooserWidget — File chooser widget that can be embedded in other widgets
#GtkFileFilter — A filter for selecting a file subset
#GtkFontButton — A button to launch a font selection dialog
#GtkFontSelection — A widget for selecting fonts
#GtkFontSelectionDialog — A dialog box for selecting fonts
#GtkInputDialog — Configure devices for the XInput extension

function push!(widget::GtkDialog, text::AbstractString, response::Integer)
    ccall((:gtk_dialog_add_button, libgtk), Ptr{GObject},
          (Ptr{GObject}, Ptr{UInt8}, Cint), widget, text, response)
    return widget
end

function response(widget::GtkDialog, response_id::Integer)
    ccall((:gtk_dialog_response, libgtk), Cvoid,
       (Ptr{GObject}, Cint),
       widget, response_id)
end

#if VERSION >= v"0.4-"
#GtkFileChooserDialogLeaf(title::AbstractString, parent::GtkContainer, action::Integer, button_text_response::= >...; kwargs...) =
#    GtkFileChooserDialogLeaf(title::AbstractString, parent, action, button_text_response; kwargs...)
#end
function GtkFileChooserDialogLeaf(title::AbstractString, parent::GtkContainer, action::Integer, button_text_response; kwargs...)
    w = GtkFileChooserDialogLeaf(ccall((:gtk_file_chooser_dialog_new, libgtk), Ptr{GObject},
                (Ptr{UInt8}, Ptr{GObject}, Cint, Ptr{Nothing}),
                title, parent, action, C_NULL); kwargs...)
    for (k, v) in button_text_response
        push!(w, k, v)
    end
    return w
end

function GtkFileChooserNativeLeaf(title::AbstractString, parent::GtkContainer, action::Integer, open::AbstractString, cancel::AbstractString; kwargs...)
    w = GtkFileChooserNativeLeaf(ccall((:gtk_file_chooser_native_new, libgtk), Ptr{GObject},
                (Ptr{UInt8}, Ptr{GObject}, Cint, Ptr{UInt8}, Ptr{UInt8}),
                title, parent, action, open, cancel); kwargs...)
    return w
end

run(widget::GtkDialog) = GLib.g_sigatom() do
    ccall((:gtk_dialog_run, libgtk), Cint, (Ptr{GObject},), widget)
end

run(widget::GtkNativeDialog) = GLib.g_sigatom() do
    ccall((:gtk_native_dialog_run, libgtk), Cint, (Ptr{GObject},), widget)
end

const SingleComma = r"(?<!,), (?!,)"
function GtkFileFilterLeaf(; name::Union{AbstractString, Nothing} = nothing, pattern::AbstractString = "", mimetype::AbstractString = "")
    filt = GtkFileFilterLeaf(ccall((:gtk_file_filter_new, libgtk), Ptr{GObject}, ()))
    if !isempty(pattern)
        name == nothing && (name = pattern)
        for p in split(pattern, SingleComma)
            p = replace(p, ", , " => ", ")   # escape sequence for , is , ,
            ccall((:gtk_file_filter_add_pattern, libgtk), Nothing, (Ptr{GObject}, Ptr{UInt8}), filt, p)
        end
    elseif !isempty(mimetype)
        name == nothing && (name = mimetype)
        for m in split(mimetype, SingleComma)
            m = replace(m, ", , " => ", ")
            ccall((:gtk_file_filter_add_mime_type, libgtk), Nothing, (Ptr{GObject}, Ptr{UInt8}), filt, m)
        end
    else
        ccall((:gtk_file_filter_add_pixbuf_formats, libgtk), Nothing, (Ptr{GObject},), filt)
    end
    ccall((:gtk_file_filter_set_name, libgtk), Nothing, (Ptr{GObject}, Ptr{UInt8}), filt, name === nothing || isempty(name) ? C_NULL : name)
    return filt
end
GtkFileFilterLeaf(pattern::AbstractString; name::Union{AbstractString, Nothing} = nothing) = GtkFileFilterLeaf(; name = name, pattern = pattern)

GtkFileFilterLeaf(filter::GtkFileFilter) = filter

function makefilters!(dlgp::GtkFileChooser, filters::Union{AbstractVector, Tuple})
    for f in filters
        ccall((:gtk_file_chooser_add_filter, libgtk), Nothing, (Ptr{GObject}, Ptr{GObject}), dlgp, GtkFileFilter(f))
    end
end

function open_dialog(title::AbstractString, parent = GtkNullContainer(), filters::Union{AbstractVector, Tuple} = String[];
                     current_folder::Union{AbstractString, Nothing} = nothing, kwargs...)
    dlg = GtkFileChooserDialog(title, parent, GConstants.GtkFileChooserAction.OPEN,
                                (("_Cancel", GConstants.GtkResponseType.CANCEL),
                                 ("_Open",   GConstants.GtkResponseType.ACCEPT)); kwargs...)
    dlgp = GtkFileChooser(dlg)
    if !isempty(filters)
        makefilters!(dlgp, filters)
    end
    if !isnothing(current_folder)
        ccall((:gtk_file_chooser_set_current_folder, libgtk), Nothing, (Ptr{GObject}, Ptr{UInt8}), dlgp, current_folder)
    end
    response = run(dlg)
    multiple = get_gtk_property(dlg, :select_multiple, Bool)
    local selection
    if response == GConstants.GtkResponseType.ACCEPT
        if multiple
            filename_list = ccall((:gtk_file_chooser_get_filenames, libgtk), Ptr{_GSList{String}}, (Ptr{GObject},), dlgp)
            selection = String[f for f in GList(filename_list, #=transfer-full=#true)]
        else
            selection = bytestring(GAccessor.filename(dlgp))
        end
    else
        if multiple
            selection = String[]
        else
            selection = ""
        end
    end
    destroy(dlg)
    return selection
end

function open_dialog_native(title::AbstractString, parent = GtkNullContainer(), filters::Union{AbstractVector, Tuple} = String[];
                            current_folder::Union{AbstractString, Nothing} = nothing, kwargs...)
    dlg = GtkFileChooserNative(title, parent, GConstants.GtkFileChooserAction.OPEN,"_Open","_Cancel"; kwargs...)
    dlgp = GtkFileChooser(dlg)
    if !isempty(filters)
        makefilters!(dlgp, filters)
    end
    if !isnothing(current_folder)
        ccall((:gtk_file_chooser_set_current_folder, libgtk), Nothing, (Ptr{GObject}, Ptr{UInt8}), dlgp, current_folder)
    end
    response = run(dlg)
    multiple = get_gtk_property(dlg, :select_multiple, Bool)
    local selection
    if response == GConstants.GtkResponseType.ACCEPT
        if multiple
            filename_list = ccall((:gtk_file_chooser_get_filenames, libgtk), Ptr{_GSList{String}}, (Ptr{GObject},), dlgp)
            selection = String[f for f in GList(filename_list, #=transfer-full=#true)]
        else
            selection = bytestring(GAccessor.filename(dlgp))
        end
    else
        if multiple
            selection = String[]
        else
            selection = ""
        end
    end
    GLib.gc_unref(dlg) #destroy(dlg)
    return selection
end

function save_dialog(title::AbstractString, parent = GtkNullContainer(), filters::Union{AbstractVector, Tuple} = String[];
                     current_folder::Union{AbstractString, Nothing} = nothing,
                     current_name::Union{AbstractString, Nothing} = nothing, kwargs...)
    dlg = GtkFileChooserDialog(title, parent, GConstants.GtkFileChooserAction.SAVE,
                                (("_Cancel", GConstants.GtkResponseType.CANCEL),
                                 ("_Save",   GConstants.GtkResponseType.ACCEPT)); kwargs...)
    dlgp = GtkFileChooser(dlg)
    if !isempty(filters)
        makefilters!(dlgp, filters)
    end
    if !isnothing(current_folder)
        ccall((:gtk_file_chooser_set_current_folder, libgtk), Nothing, (Ptr{GObject}, Ptr{UInt8}), dlgp, current_folder)
    end
    if !isnothing(current_name)
        ccall((:gtk_file_chooser_set_current_name, libgtk), Nothing, (Ptr{GObject}, Ptr{UInt8}), dlgp, current_name)
    end
    ccall((:gtk_file_chooser_set_do_overwrite_confirmation, libgtk), Nothing, (Ptr{GObject}, Cint), dlg, true)
    response = run(dlg)
    if response == GConstants.GtkResponseType.ACCEPT
        selection = bytestring(GAccessor.filename(dlgp))
    else
        selection = ""
    end
    destroy(dlg)
    return selection
end

function save_dialog_native(title::AbstractString, parent = GtkNullContainer(), filters::Union{AbstractVector, Tuple} = String[];
                            current_folder::Union{AbstractString, Nothing} = nothing,
                            current_name::Union{AbstractString, Nothing} = nothing, kwargs...)
    dlg = GtkFileChooserNative(title, parent, GConstants.GtkFileChooserAction.SAVE,"_Save","_Cancel"; kwargs...)
    dlgp = GtkFileChooser(dlg)
    if !isempty(filters)
        makefilters!(dlgp, filters)
    end
    if !isnothing(current_folder)
        ccall((:gtk_file_chooser_set_current_folder, libgtk), Nothing, (Ptr{GObject}, Ptr{UInt8}), dlgp, current_folder)
    end
    if !isnothing(current_name)
        ccall((:gtk_file_chooser_set_current_name, libgtk), Nothing, (Ptr{GObject}, Ptr{UInt8}), dlgp, current_name)
    end
    ccall((:gtk_file_chooser_set_do_overwrite_confirmation, libgtk), Nothing, (Ptr{GObject}, Cint), dlg, true)
    response = run(dlg)
    if response == GConstants.GtkResponseType.ACCEPT
        selection = bytestring(GAccessor.filename(dlgp))
    else
        selection = ""
    end
    GLib.gc_unref(dlg) #destroy(dlg)
    return selection
end

function GtkColorChooserDialogLeaf(title::AbstractString, parent::GtkContainer; kwargs...)
    return GtkColorChooserDialogLeaf(ccall((:gtk_color_chooser_dialog_new, libgtk), Ptr{GObject},
            (Ptr{UInt8}, Ptr{GObject}),
            title, parent); kwargs...)
end

function color_chooser_dialog(title::AbstractString, parent = GtkNullContainer(); kwargs...)
    dlg = GtkColorChooserDialog(title, parent; kwargs...)
    response = run(dlg)
    if response == GConstants.GtkResponseType.OK
        selection = GAccessor.rgba(dlg)
    else
        selection = nothing
    end
    destroy(dlg)
    return selection
end