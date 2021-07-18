function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    precompile(Tuple{typeof(__init__)})
    precompile(Tuple{typeof(gtk_main)})
    precompile(Tuple{Type{GtkWindow},String})
    precompile(Tuple{Type{GtkWindowLeaf},String,Int,Int})
    precompile(Tuple{Type{GtkMenu}})
    precompile(Tuple{Type{GtkMenuItem},String})
    precompile(Tuple{Type{GtkFrameLeaf},Ptr{GObject}})
    precompile(Tuple{Type{GtkBox},Symbol})
    precompile(Tuple{Type{GtkButtonLeaf},Ptr{GObject}})
    precompile(Tuple{Type{GtkToolButton},String})
    precompile(Tuple{Type{GtkToolbar}})
    precompile(Tuple{Type{GtkCanvas},Int,Int})
    # precompile(Tuple{typeof(signal_emit),GtkCanvas,String,Type,GdkEventScroll})
    # precompile(Tuple{typeof(signal_emit),GtkCanvas,String,Type,GdkEventMotion})
    # precompile(Tuple{typeof(signal_emit),GtkCanvas,String,Type,GdkEventButton})
    # precompile(Tuple{typeof(signal_emit),GtkEntryLeaf,Symbol,Type})
    precompile(Tuple{typeof(signal_connect),Function,GtkComboBoxTextLeaf,Symbol})
    precompile(Tuple{typeof(setindex!),Dict{Union{WeakRef, GObject},Bool},Bool,GtkTextBufferLeaf})
    precompile(Tuple{typeof(notify_realize),Ptr{GObject},GtkCanvas})
    precompile(Tuple{typeof(mouseup_cb),Ptr{GObject},Ptr{GdkEventButton},MouseHandler})   # time: 0.026400313
    precompile(Tuple{typeof(toplevel),GtkCanvas})   # time: 0.023317223
    precompile(Tuple{typeof(notify_motion),Ptr{GObject},Ptr{GdkEventMotion},Gtk_signal_motion{MouseHandler}})   # time: 0.001248276
    precompile(Tuple{typeof(canvas_on_draw_event),Ptr{GObject},Ptr{Nothing},GtkCanvas})   # time: 0.001126875
    precompile(Tuple{typeof(mousedown_cb),Ptr{GObject},Ptr{GdkEventButton},MouseHandler})   # time: 0.001090291
    precompile(Tuple{typeof(signal_connect),typeof(notify_realize), GtkCanvas, String, Type{Nothing}, Tuple{}})
    precompile(Tuple{typeof(open_dialog),String,GtkWindowLeaf,Tuple{String}})
    precompile(Tuple{typeof(open_dialog),String,GtkWindowLeaf,Tuple{String,String}})
    precompile(Tuple{typeof(save_dialog),String,GtkWindowLeaf,Tuple{String}})
    precompile(Tuple{Type{GtkFileChooserDialogLeaf},String,GtkWindowLeaf,Int32,Tuple{Tuple{String, Int32}, Tuple{String, Int32}}})
    precompile(Tuple{Type{GtkFileFilterLeaf},String})
    precompile(Tuple{typeof(makefilters!),GtkFileChooser,Tuple{String, String}})
    precompile(Tuple{typeof(draw),GtkCanvas,Bool})
    for T in Any[
        GtkWindowLeaf,
        GtkMenuLeaf,
        GtkMenuItemLeaf,
        GtkFrameLeaf,
        GtkBoxLeaf,
        GtkButtonLeaf,
        GtkToolButtonLeaf,
        GtkCanvas,
        # GtkWidget,
        GtkProgressBarLeaf,
        GtkLabelLeaf,
        GtkScaleLeaf,
        GtkBuilderLeaf,
        GtkEntryLeaf,
        GtkSpinButtonLeaf,
        GtkToggleButtonLeaf,
        GtkCheckButtonLeaf,
        GtkComboBoxTextLeaf,
        GtkAspectFrameLeaf,
        # GtkLabel,
        GtkAdjustmentLeaf,
        # GObject,
        GtkTextBufferLeaf,
        GtkTextViewLeaf,
        # GtkTextBuffer,
        GtkGridLeaf,
    ]
        precompile(Tuple{typeof(GLib.gobject_ref), T})
    end
end
