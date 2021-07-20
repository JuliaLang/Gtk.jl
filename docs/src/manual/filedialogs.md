# Dialogs

## File Dialogs

Gtk.jl supports the `GtkFileChooserDialog` and the `GtkFileChooserNative`.
It also provides four functions, `open_dialog` and `save_dialog` as well as `open_dialog_native` and `save_dialog_native`, making this functionality easier to use.
The syntax of these four functions are as follows:

```julia
open_dialog(title, GtkNullContainer(), String[])
save_dialog(title, GtkNullContainer(), String[])
open_dialog_native(title, GtkNullContainer(), String[])
save_dialog_native(title, GtkNullContainer(), String[])
```

If you are using these functions in the context of a GUI, you should set the parent to be the top-level window.
Otherwise, for standalone usage in scripts, do not set the parent.

The main flexibility comes from the filters, which can be specified as a Tuple or Vector.
A filter can be specified as a string, in which case it specifies a globbing pattern, for example `"*.png"`.
You can specify multiple match types for a single filter by separating the patterns with a comma, for example `"*.png,*.jpg"`.
You can alternatively specify MIME types, or if no specification is provided it defaults to types supported by `GdkPixbuf`.
The generic specification of a filter is
```julia
GtkFileFilter(; name = nothing, pattern = "", mimetype = "")
```

If on the other hand you want to choose a folder instead of a file, set the `action` to `GtkFileChooserAction.SELECT_FOLDER`:
```julia
dir = open_dialog("Select Dataset Folder", action=GtkFileChooserAction.SELECT_FOLDER)
if isdir(dir)
   # do something with dir
end
```

The open and save dialogs (incl. native versions) support the keyword argument `current_folder`
to set the current folder shown when the dialog opens. Both save dialog variants support an additional
keyword argument, `current_name`, to allow suggesting a filename for saving.

Here are some examples:
```julia
open_dialog("Pick a file")
open_dialog("Pick a file"; current_folder=homedir())
open_dialog("Pick some files", select_multiple=true)
open_dialog("Pick a file", Null(), ("*.jl",))
open_dialog("Pick some text files", GtkNullContainer(), ("*.txt, *.csv",), select_multiple=true)
open_dialog("Pick a file", Null(), (GtkFileFilter(mimetype="text/csv"),))
open_dialog("Pick an image file", GtkNullContainer(), ("*.png", "*.jpg", GtkFileFilter("*.png, *.jpg", name="All supported formats")))
open_dialog("Pick an image file", GtkNullContainer(), (GtkFileFilter(name="Supported image formats"),))

save_dialog("Save as...", Null(), (GtkFileFilter("*.png, *.jpg", name="All supported formats"), "*.png", "*.jpg"))
save_dialog("Save as...", Null(), (GtkFileFilter("*.png, *.jpg", name="All supported formats"), "*.png", "*.jpg");
            current_name="Profile.jpg")
```



## Message dialogs

Gtk.jl also supports `GtkMessageDialog` and provides several convenience functions:  `info_dialog`, `ask_dialog`, `warn_dialog`, and `error_dialog`.  Each inputs a string and an optional parent container, and returns nothing, except for `ask_dialog` which returns true if the user clicked `yes`.


```jl
info_dialog("Julia rocks!")
ask_dialog("Do you like chocolate ice cream?", "Not at all", "I like it") && println("That's my favorite too.")
warn_dialog("Oops!... I did it again")
```
