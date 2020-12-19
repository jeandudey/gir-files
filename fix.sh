#!/bin/bash
set -x -e

# Remove Int32 alias because it misses c:type, it not like anyone actually cares about it.
xmlstarlet ed -P -L \
	-d '///_:alias[@name="Int32"]' \
	freetype2-2.0.gir

# gir uses error domain to find quark function corresponding to given error enum,
# but in this case it happens to be named differently, i.e., as g_option_error_quark.
xmlstarlet ed -P -L \
	-u '//*[@glib:error-domain="g-option-context-error-quark"]/@glib:error-domain' -v g-option-error-quark \
	GLib-2.0.gir

# GtkEntry icon signals incorrect assume GdkEventButton when other variants may be passed
xmlstarlet ed -P -L \
	-u '//_:class[@name="Entry"]/glib:signal[@name="icon-press"]//_:parameter[@name="event"]/_:type[@name="Gdk.EventButton"]/@name' -v "Gdk.Event" \
	-u '//_:class[@name="Entry"]/glib:signal[@name="icon-release"]//_:parameter[@name="event"]/_:type[@name="Gdk.EventButton"]/@name' -v "Gdk.Event" \
	Gtk-3.0.gir

# GtkIconSize usage
xmlstarlet ed -P -L \
	-u '//_:type[@c:type="GtkIconSize"]/@name' -v "IconSize" \
	-u '//_:type[@c:type="GtkIconSize*"]/@name' -v "IconSize" \
	Gtk-3.0.gir

# incorrect GIR due to gobject-introspection GitLab issue #189
xmlstarlet ed -P -L \
	-u '//_:class[@name="IconTheme"]/_:method//_:parameter[@name="icon_names"]/_:array/@c:type' -v "const gchar**" \
	-u '//_:class[@name="IconTheme"]/_:method[@name="get_search_path"]//_:parameter[@name="path"]/_:array/@c:type' -v "gchar***" \
	-u '//_:class[@name="IconTheme"]/_:method[@name="set_search_path"]//_:parameter[@name="path"]/_:array/@c:type' -v "const gchar**" \
	Gtk-3.0.gir

# incorrect GIR due to gobject-introspection GitLab issue #189
xmlstarlet ed -P -L \
	-u '//_:record[@name="KeyFile"]/_:method[@name="set_boolean_list"]//_:parameter[@name="list"]/_:array/@c:type' -v "gboolean*" \
	-u '//_:record[@name="KeyFile"]/_:method[@name="set_double_list"]//_:parameter[@name="list"]/_:array/@c:type' -v "gdouble*" \
	-u '//_:record[@name="KeyFile"]/_:method[@name="set_integer_list"]//_:parameter[@name="list"]/_:array/@c:type' -v "gint*" \
	-u '//_:record[@name="KeyFile"]/_:method[@name="set_locale_string_list"]//_:parameter[@name="list"]/_:array/@c:type' -v "const gchar* const*" \
	-u '//_:record[@name="KeyFile"]/_:method[@name="set_string_list"]//_:parameter[@name="list"]/_:array/@c:type' -v "const gchar* const*" \
	GLib-2.0.gir

# incorrect GIR due to gobject-introspection GitLab issue #189
xmlstarlet ed -P -L \
	-u '//_:class[@name="Object"]/_:method[@name="getv"]//_:parameter[@name="names"]/_:array/@c:type' -v "const gchar**" \
	-u '//_:class[@name="Object"]/_:method[@name="getv"]//_:parameter[@name="values"]/_:array/@c:type' -v "GValue*" \
	-u '//_:class[@name="Object"]/_:method[@name="setv"]//_:parameter[@name="names"]/_:array/@c:type' -v "const gchar**" \
	-u '//_:class[@name="Object"]/_:method[@name="setv"]//_:parameter[@name="values"]/_:array/@c:type' -v "const GValue*" \
	-u '//_:class[@name="Object"]/_:constructor[@name="new_with_properties"]//_:parameter[@name="names"]/_:array/@c:type' -v "const char**" \
	-u '//_:class[@name="Object"]/_:constructor[@name="new_with_properties"]//_:parameter[@name="values"]/_:array/@c:type' -v "const GValue*" \
	GObject-2.0.gir

# fix wrong "full" transfer ownership
xmlstarlet ed -P -L \
	-u '//_:method[@c:identifier="gdk_frame_clock_get_current_timings"]/_:return-value/@transfer-ownership' -v "none" \
	-u '//_:method[@c:identifier="gdk_frame_clock_get_timings"]/_:return-value/@transfer-ownership' -v "none" \
	Gdk-3.0.gir

# replace "gint" response_id parameters with "ResponseType"
xmlstarlet ed -P -L \
	-u '//_:parameter[@name="response_id"]/_:type[@name="gint"]/@c:type' -v "GtkResponseType" \
	-u '//_:parameter[@name="response_id"]/_:type[@name="gint"]/@name' -v "ResponseType" \
	Gtk-3.0.gir Gtk-4.0.gir

# fix wrong "full" transfer ownership
xmlstarlet ed -P -L \
	-u '//_:constructor[@c:identifier="gtk_shortcut_label_new"]/_:return-value/@transfer-ownership' -v "none" \
	Gtk-3.0.gir Gtk-4.0.gir

# add out annotation for functions returning GValue
xmlstarlet ed -P -L \
	-a '//_:method[@c:identifier="gtk_style_context_get_style_property"]//_:parameter[@name="value" and not(@direction)]' -type attr -n "direction" -v "out" \
	-a '//_:method[@c:identifier="gtk_style_context_get_style_property"]//_:parameter[@name="value" and not(@caller-allocates)]' -type attr -n "caller-allocates" -v "1" \
	-a '//_:method[@c:identifier="gtk_cell_area_cell_get_property"]//_:parameter[@name="value" and not(@direction)]' -type attr -n "direction" -v "out" \
	-a '//_:method[@c:identifier="gtk_cell_area_cell_get_property"]//_:parameter[@name="value" and not(@caller-allocates)]' -type attr -n "caller-allocates" -v "1" \
	-a '//_:method[@c:identifier="gtk_container_child_get_property"]//_:parameter[@name="value" and not(@direction)]' -type attr -n "direction" -v "out" \
	-a '//_:method[@c:identifier="gtk_container_child_get_property"]//_:parameter[@name="value" and not(@caller-allocates)]' -type attr -n "caller-allocates" -v "1" \
	-a '//_:method[@c:identifier="gtk_widget_style_get_property"]//_:parameter[@name="value" and not(@direction)]' -type attr -n "direction" -v "out" \
	-a '//_:method[@c:identifier="gtk_widget_style_get_property"]//_:parameter[@name="value" and not(@caller-allocates)]' -type attr -n "caller-allocates" -v "1" \
	Gtk-3.0.gir

xmlstarlet tr JavaScriptCore-4.0.xsl JavaScriptCore-4.0.gir | xmlstarlet fo > JavaScriptCore-4.0.gir.tmp
mv JavaScriptCore-4.0.gir.tmp JavaScriptCore-4.0.gir

# fill in types from JavaScriptCore
xmlstarlet ed -P -L \
	-i '///_:type[not(@name) and @c:type="JSGlobalContextRef"]' -t 'attr' -n 'name' -v "JavaScriptCore.GlobalContextRef" \
	-i '///_:type[not(@name) and @c:type="JSValueRef"]' -t 'attr' -n 'name' -v "JavaScriptCore.ValueRef" \
	WebKit2WebExtension-4.0.gir WebKit2-4.0.gir

xmlstarlet ed -P -L \
	-u '//_:constant[@name="DOM_NODE_FILTER_SHOW_ALL"]/_:type/@name' -v "guint" \
	-u '//_:constant[@name="DOM_NODE_FILTER_SHOW_ALL"]/_:type/@c:type' -v "guint" \
	WebKit2WebExtension-4.0.gir


# remove freetype and graphite methods; GitHub issue #2557
xmlstarlet ed -P -L \
	-d '///_:function[@c:identifier="hb_graphite2_face_get_gr_face"]' \
	-d '///_:function[@c:identifier="hb_graphite2_font_get_gr_font"]' \
	-d '///_:function[@c:identifier="hb_ft_face_create"]' \
	-d '///_:function[@c:identifier="hb_ft_face_create_cached"]' \
	-d '///_:function[@c:identifier="hb_ft_face_create_referenced"]' \
	-d '///_:function[@c:identifier="hb_ft_font_create"]' \
	-d '///_:function[@c:identifier="hb_ft_font_create_cached"]' \
	-d '///_:function[@c:identifier="hb_ft_font_create_referenced"]' \
	-d '///_:function[@c:identifier="hb_ft_font_get_face"]' \
	-d '///_:function[@c:identifier="hb_ft_font_lock_face"]' \
	HarfBuzz-0.0.gir

# fix harfbuzz types on Pango
xmlstarlet ed -P -L \
	-i '///_:type[not(@name) and @c:type="hb_font_t*"]' -t 'attr' -n 'name' -v "gconstpointer" \
	-u '//_:type[@c:type="hb_font_t*"]/@c:type' -v "gconstpointer" \
	-i '///_:array[not(@name) and @c:type="hb_feature_t*"]' -t 'attr' -n 'name' -v "gconstpointer" \
	-r '///_:array[@c:type="hb_feature_t*"]' -v "type" \
	-d '//_:type[@c:type="hb_feature_t*"]/*' \
	-d '//_:type[@c:type="hb_feature_t*"]/@length' \
	-d '//_:type[@c:type="hb_feature_t*"]/@zero-terminated' \
	-u '//_:type[@c:type="hb_feature_t*"]/@c:type' -v "gconstpointer" \
	Pango-1.0.gir

#  Remove unstable method from focal release
xmlstarlet ed -P -L \
  	-d '///_:method[@c:identifier="atk_plug_set_child"]' \
  	Atk-1.0.gir

# fix non-existant c-types
xmlstarlet ed -P -L \
	-u '//_:class[@name="WaylandDevice"]/_:method[@name="get_wl_keyboard"]//_:type[@name="gpointer"]/@c:type' -v "gpointer" \
	-u '//_:class[@name="WaylandDevice"]/_:method[@name="get_wl_pointer"]//_:type[@name="gpointer"]/@c:type' -v "gpointer" \
	-u '//_:class[@name="WaylandDevice"]/_:method[@name="get_wl_seat"]//_:type[@name="gpointer"]/@c:type' -v "gpointer" \
	-u '//_:class[@name="WaylandDisplay"]/_:method[@name="get_wl_compositor"]//_:type[@name="gpointer"]/@c:type' -v "gpointer" \
	-u '//_:class[@name="WaylandDisplay"]/_:method[@name="get_wl_display"]//_:type[@name="gpointer"]/@c:type' -v "gpointer" \
	-u '//_:class[@name="WaylandMonitor"]/_:method[@name="get_wl_output"]//_:type[@name="gpointer"]/@c:type' -v "gpointer" \
	-u '//_:class[@name="WaylandSeat"]/_:method[@name="get_wl_seat"]//_:type[@name="gpointer"]/@c:type' -v "gpointer" \
	-u '//_:class[@name="WaylandSurface"]/_:method[@name="get_wl_surface"]//_:type[@name="gpointer"]/@c:type' -v "gpointer" \
	GdkWayland-4.0.gir

 Fix almost all
xmlstarlet ed -P -L \
	-a '//_:class[@name="AbstractBidirList"]' -t "attr" -n "c:symbol-prefix" -v "abstract_bidir_list" \
    -d '///_:method/_:return-value/_:type/_:type[@name="gpointer" and @c:type="gpointer"]' \
    -d '///_:virtual-method/_:return-value/_:type/_:type[@name="gpointer" and @c:type="gpointer"]' \
    -d '///_:property/_:type/_:type[@name="gpointer" and @c:type="gpointer"]' \
    -d '//_:record/_:field/_:callback/_:return-value/_:type/_:type[@name="gpointer" and @c:type="gpointer"]' \
    -d '//_:record/_:field/_:callback/_:parameters/_:parameter/_:type/_:type[@name="gpointer" and @c:type="gpointer"]' \
    -a '//_:record/_:field/_:callback/_:return-value/_:type[@name="none"]' -t "attr" -n "c:type" -v "void" \
    -u '//_:record/_:field/_:callback/_:return-value/_:type[@name="none"]/@c:name' -v "void" \
	-a '//_:class[@name="AbstractBidirSortedSet"]' -t "attr" -n "c:symbol-prefix" -v "abstract_bidir_list_sorted_set" \
	-a '//_:class[@name="AbstractBidirSortedMap"]' -t "attr" -n "c:symbol-prefix" -v "abstract_bidir_list_sorted_map" \
	-a '//_:class[@name="AbstractCollection"]' -t "attr" -n "c:symbol-prefix" -v "abstract_collection" \
    -a '///_:method/_:return-value/_:type[@name="none"]' -t "attr" -n "c:type" -v "void" \
    -u '///_:method/_:return-value/_:type[@name="none"]/@c:name' -v "void" \
	-a '//_:class[@name="AbstractList"]' -t "attr" -n "c:symbol-prefix" -v "abstract_list" \
	-a '//_:class[@name="AbstractMap"]' -t "attr" -n "c:symbol-prefix" -v "abstract_map" \
    -d '///_:virtual-method/_:return-value/_:type/_:type[@name="gpointer" and @c:type="gpointer"]' \
    -d '///_:property/_:type[@name="Gee.Set"]/*' \
    -d '///_:method/_:return-value/_:type[@name="Gee.Set"]/*' \
	-a '//_:class[@name="AbstractMultiMap"]' -t "attr" -n "c:symbol-prefix" -v "abstract_multi_map" \
    -d '///_:field/_:type[@name="Gee.Map"]/*' \
	-a '//_:class[@name="AbstractMultiSet"]' -t "attr" -n "c:symbol-prefix" -v "abstract_multi_set" \
	-a '//_:class[@name="AbstractQueue"]' -t "attr" -n "c:symbol-prefix" -v "abstract_queue" \
	-a '//_:class[@name="AbstractSet"]' -t "attr" -n "c:symbol-prefix" -v "abstract_set" \
	-a '//_:class[@name="AbstractSortedMap"]' -t "attr" -n "c:symbol-prefix" -v "abstract_sorted_map" \
    -d '///_:property/_:type[@name="Gee.SortedSet"]/*' \
    -d '///_:method/_:return-value/_:type[@name="Gee.SortedSet"]/*' \
	-a '//_:class[@name="AbstractSortedSet"]' -t "attr" -n "c:symbol-prefix" -v "abstract_sorted_set" \
	-a '//_:class[@name="ArrayList"]' -t "attr" -n "c:symbol-prefix" -v "array_list" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.ArrayList"]/*' \
    -d '///_:method/_:parameters/_:parameter/_:type[@name="Gee.Collection"]/*' \
	-a '//_:class[@name="ArrayQueue"]' -t "attr" -n "c:symbol-prefix" -v "array_queue" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.ArrayQueue"]/*' \
	-a '//_:class[@name="ConcurrentList"]' -t "attr" -n "c:symbol-prefix" -v "concurrent_list" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.ConcurrentList"]/*' \
	-a '//_:class[@name="ConcurrentSet"]' -t "attr" -n "c:symbol-prefix" -v "concurrent_set" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.ConcurrentSet"]/*' \
	-a '//_:class[@name="HashMap"]' -t "attr" -n "c:symbol-prefix" -v "hash_map" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.HashMap"]/*' \
	-a '//_:class[@name="HashMultiMap"]' -t "attr" -n "c:symbol-prefix" -v "hash_multi_map" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.HashMultiMap"]/*' \
	-a '//_:class[@name="HashMultiSet"]' -t "attr" -n "c:symbol-prefix" -v "hash_multi_set" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.HashMultiSet"]/*' \
	-a '//_:class[@name="HashSet"]' -t "attr" -n "c:symbol-prefix" -v "hash_set" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.HashSet"]/*' \
	-a '//_:record[@name="HazardPointer"]' -t "attr" -n "c:type" -v "GeeHazardPointer" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.HazardPointer"]/*' \
    -d '///_:function/_:return-value/_:type[@name="Gee.HazardPointer"]/*' \
    -a '///_:function/_:return-value/_:type[@name="none"]' -t "attr" -n "c:type" -v "void" \
    -u '///_:function/_:return-value/_:type[@name="none"]/@c:name' -v "void" \
    -a '//_:record[@name="HazardPointerContext"]' -t "attr" -n "c:type" -v "GeeHazardPointerContext" \
	-a '//_:class[@name="Lazy"]' -t "attr" -n "c:symbol-prefix" -v "lazy" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.Lazy"]/*' \
	-a '//_:class[@name="LinkedList"]' -t "attr" -n "c:symbol-prefix" -v "linked_list" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.LinkedList"]/*' \
	-a '//_:class[@name="PriorityQueue"]' -t "attr" -n "c:symbol-prefix" -v "priority_queue" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.PriorityQueue"]/*' \
	-a '//_:class[@name="Promise"]' -t "attr" -n "c:symbol-prefix" -v "promise" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.Promise"]/*' \
	-a '//_:class[@name="TreeMap"]' -t "attr" -n "c:symbol-prefix" -v "tree_map" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.TreeMap"]/*' \
	-a '//_:class[@name="TreeMultiMap"]' -t "attr" -n "c:symbol-prefix" -v "tree_multi_map" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.TreeMultiMap"]/*' \
	-a '//_:class[@name="TreeMultiSet"]' -t "attr" -n "c:symbol-prefix" -v "tree_multi_set" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.TreeMultiSet"]/*' \
	-a '//_:class[@name="TreeSet"]' -t "attr" -n "c:symbol-prefix" -v "tree_set" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.TreeSet"]/*' \
	-a '//_:class[@name="UnrolledLinkedList"]' -t "attr" -n "c:symbol-prefix" -v "unrolled_linked_list" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.UnrolledLinkedList"]/*' \
	-a '//_:interface[@name="BidirIterator"]' -t "attr" -n "c:symbol-prefix" -v "bidir_iterator" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.BidirIterator"]/*' \
	-a '//_:interface[@name="BidirList"]' -t "attr" -n "c:symbol-prefix" -v "bidir_list" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.BidirList"]/*' \
	-a '//_:interface[@name="BidirListIterator"]' -t "attr" -n "c:symbol-prefix" -v "bidir_list_iterator" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.BidirListIterator"]/*' \
	-a '//_:interface[@name="BidirMapIterator"]' -t "attr" -n "c:symbol-prefix" -v "bidir_map_iterator" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.BidirMapIterator"]/*' \
	-a '//_:interface[@name="BidirSortedSet"]' -t "attr" -n "c:symbol-prefix" -v "bidir_sorted_set" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.BidirSortedSet"]/*' \
    -d '///_:function/_:return-value/_:type[@name="Gee.BidirSortedSet"]/*' \
	-a '//_:interface[@name="BidirSortedMap"]' -t "attr" -n "c:symbol-prefix" -v "bidir_sorted_map" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.BidirSortedMap"]/*' \
    -d '///_:function/_:return-value/_:type[@name="Gee.BidirSortedMap"]/*' \
	-a '//_:interface[@name="Collection"]' -t "attr" -n "c:symbol-prefix" -v "collection" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.Collection"]/*' \
    -d '///_:function/_:return-value/_:type[@name="Gee.Collection"]/*' \
    -d '///_:method/_:parameters/_:parameter/_:type[@name="Gee.Iterator"]/*' \
	-a '//_:interface[@name="Comparable"]' -t "attr" -n "c:symbol-prefix" -v "comparable" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.Comparable"]/*' \
	-a '//_:interface[@name="Deque"]' -t "attr" -n "c:symbol-prefix" -v "deque" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.Deque"]/*' \
	-a '//_:interface[@name="Future"]' -t "attr" -n "c:symbol-prefix" -v "future" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.Future"]/*' \
    -d '///_:method/_:parameters/_:parameter/_:type[@name="Gee.Future"]/*' \
    -u '//_:interface[@name="Future"]/_:callback[@name="FlatMapFunc"]/@name' -v "FutureFlatMapFunc" \
    -u '//_:interface[@name="Future"]/_:callback[@name="LightMapFunc"]/@name' -v "FutureLightMapFunc" \
    -u '//_:interface[@name="Future"]/_:callback[@name="ZipFunc"]/@name' -v "FutureZipFunc" \
    -u '//_:interface[@name="Future"]/_:callback[@name="MapFunc"]/@name' -v "FutureMapFunc" \
    -m '//_:interface[@name="Future"]/_:callback' '//_:namespace[@name="Gee"]' \
    -d '///_:callback/_:return-value/_:type[@name="Gee.Iterator"]/*' \
	-a '//_:interface[@name="Hashable"]' -t "attr" -n "c:symbol-prefix" -v "hashable" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.Hashable"]/*' \
    -d '///_:method/_:parameters/_:parameter/_:type[@name="Gee.Hashable"]/*' \
	-a '//_:interface[@name="Iterable"]' -t "attr" -n "c:symbol-prefix" -v "iterable" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.Iterable"]/*' \
    -d '///_:method/_:parameters/_:parameter/_:type[@name="Gee.Iterable"]/*' \
	-a '//_:interface[@name="Iterator"]' -t "attr" -n "c:symbol-prefix" -v "iterator" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.Iterator"]/*' \
    -d '///_:method/_:parameters/_:parameter/_:type[@name="Gee.Iterator"]/*' \
    -d '///_:function/_:return-value/_:type[@name="Gee.Iterator"]/*' \
    -d '///_:function/_:parameters/_:parameter/_:type[@name="Gee.Lazy"]/*' \
    -d '///_:function/_:parameters/_:parameter/_:type[@name="Gee.Iterator"]/*' \
	-a '//_:interface[@name="List"]' -t "attr" -n "c:symbol-prefix" -v "list" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.List"]/*' \
    -d '///_:method/_:parameters/_:parameter/_:type[@name="Gee.List"]/*' \
    -d '///_:function/_:return-value/_:type[@name="Gee.List"]/*' \
	-a '//_:interface[@name="ListIterator"]' -t "attr" -n "c:symbol-prefix" -v "list_iterator" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.ListIterator"]/*' \
    -d '///_:method/_:parameters/_:parameter/_:type[@name="Gee.ListIterator"]/*' \
	-a '//_:interface[@name="Map"]' -t "attr" -n "c:symbol-prefix" -v "map" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.Map"]/*' \
    -d '///_:method/_:parameters/_:parameter/_:type[@name="Gee.Map"]/*' \
    -d '///_:function/_:return-value/_:type[@name="Gee.Map"]/*' \
    -d '////_:callback/_:return-value/_:type[@name="Gee.Set"]/*' \
	-a '//_:class[@name="MapEntry"]' -t "attr" -n "c:symbol-prefix" -v "map_entry" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.MapEntry"]/*' \
	-a '//_:interface[@name="MapIterator"]' -t "attr" -n "c:symbol-prefix" -v "map_iterator" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.MapIterator"]/*' \
    -d '///_:method/_:parameters/_:parameter/_:type[@name="Gee.MapIterator"]/*' \
	-a '//_:interface[@name="MultiMap"]' -t "attr" -n "c:symbol-prefix" -v "multi_map" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.MultiMap"]/*' \
    -d '///_:method/_:parameters/_:parameter/_:type[@name="Gee.MultiMap"]/*' \
	-a '//_:interface[@name="MultiSet"]' -t "attr" -n "c:symbol-prefix" -v "multi_set" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.MultiSet"]/*' \
    -d '///_:method/_:parameters/_:parameter/_:type[@name="Gee.MultiSet"]/*' \
    -d '///_:function/_:return-value/_:type[@name="Gee.Set"]/*' \
	-a '//_:interface[@name="Queue"]' -t "attr" -n "c:symbol-prefix" -v "queue" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.Queue"]/*' \
    -d '///_:method/_:parameters/_:parameter/_:type[@name="Gee.Queue"]/*' \
    -d '///_:constant[@name="UNBOUNDED_CAPACITY"]' \
	-a '//_:interface[@name="Set"]' -t "attr" -n "c:symbol-prefix" -v "set" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.Set"]/*' \
    -d '///_:method/_:parameters/_:parameter/_:type[@name="Gee.Set"]/*' \
	-a '//_:interface[@name="SortedMap"]' -t "attr" -n "c:symbol-prefix" -v "sorted_map" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.SortedMap"]/*' \
    -d '///_:method/_:parameters/_:parameter/_:type[@name="Gee.SortedMap"]/*' \
    -d '////_:callback/_:return-value/_:type[@name="Gee.SortedSet"]/*' \
	-a '//_:interface[@name="SortedSet"]' -t "attr" -n "c:symbol-prefix" -v "sorted_set" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.SortedSet"]/*' \
    -d '///_:method/_:parameters/_:parameter/_:type[@name="Gee.SortedSet"]/*' \
    -d '///_:function/_:return-value/_:type[@name="Gee.SortedSet"]/*' \
	-a '//_:interface[@name="Traversable"]' -t "attr" -n "c:symbol-prefix" -v "traversable" \
    -d '///_:constructor/_:return-value/_:type[@name="Gee.Traversable"]/*' \
    -d '///_:method/_:parameters/_:parameter/_:type[@name="Gee.Traversable"]/*' \
    -d '///_:method/_:return-value/_:array/_:type[@name="Gee.Iterator"]/*' \
    -d '////_:callback/_:return-value/_:array/_:type[@name="Gee.Iterator"]/*' \
    -d '///_:callback/_:return-value/_:type[@name="Gee.Lazy"]/*' \
    -d '///_:callback/_:parameters/_:parameter/_:type[@name="Gee.Lazy"]/*' \
    -d '///_:function/_:return-value/_:type[@name="Gee.Future"]/*' \
    -d '//_:callback/_:return-value/_:type[@name="Gee.Future"]/*' \
    Gee-0.8.gir

xmlstarlet ed -P -L \
    -d '//_:constant' \
    -a '//_:class[@name="DrawingBufferSurface"]' -t "attr" -n "c:symbol-prefix" -v "drawing_buffer_surface" \
    -a '////_:return-value/_:type[@name="none"]' -t "attr" -n "c:type" -v "void" \
    -u '////_:return-value/_:type[@name="none"]/@c:name' -v "void" \
    -a '//_:class[@name="DrawingColor"]' -t "attr" -n "c:symbol-prefix" -v "drawing_color" \
    -a '//_:class[@name="DrawingUtilities"]' -t "attr" -n "c:symbol-prefix" -v "drawing_utilities" \
    -a '//_:class[@name="GtkPatchAboutDialog"]' -t "attr" -n "c:symbol-prefix" -v "gtk_patch_about_dialog" \
    -a '//_:class[@name="ServicesContractorProxy"]' -t "attr" -n "c:symbol-prefix" -v "services_contractor_proxy" \
    -d '////_:return-value/_:type[@name="Gee.List"]/*' \
    -a '//_:class[@name="ServicesIconFactory"]' -t "attr" -n "c:symbol-prefix" -v "services_icon_factory" \
    -a '//_:class[@name="ServicesLogger"]' -t "attr" -n "c:symbol-prefix" -v "services_logger" \
    -a '//_:class[@name="ServicesPaths"]' -t "attr" -n "c:symbol-prefix" -v "services_paths" \
    -a '//_:class[@name="ServicesSettings"]' -t "attr" -n "c:symbol-prefix" -v "services_settings" \
    -a '//_:class[@name="ServicesSimpleCommand"]' -t "attr" -n "c:symbol-prefix" -v "services_simple_command" \
    -a '//_:class[@name="ServicesSystem"]' -t "attr" -n "c:symbol-prefix" -v "services_system" \
    -a '//_:interface[@name="ServicesContract"]' -t "attr" -n "c:symbol-prefix" -v "services_contract" \
    -a '//_:interface[@name="ServicesSettingsSerializable"]' -t "attr" -n "c:symbol-prefix" -v "services_settings_serializable" \
    -a '//_:class[@name="WidgetsAboutDialog"]' -t "attr" -n "c:symbol-prefix" -v "widgets_about_dialog" \
    -a '//_:class[@name="WidgetsAlertView"]' -t "attr" -n "c:symbol-prefix" -v "widgets_alert_view" \
    -a '//_:class[@name="WidgetsAppMenu"]' -t "attr" -n "c:symbol-prefix" -v "widgets_app_menu" \
    -a '//_:class[@name="WidgetsAvatar"]' -t "attr" -n "c:symbol-prefix" -v "widgets_avatar" \
    -a '//_:class[@name="WidgetsCellRendererBadge"]' -t "attr" -n "c:symbol-prefix" -v "widgets_cell_renderer_badge" \
    -a '//_:class[@name="WidgetsCellRendererExpander"]' -t "attr" -n "c:symbol-prefix" -v "widgets_cell_renderer_expander" \
    -a '//_:class[@name="WidgetsCollapsiblePaned"]' -t "attr" -n "c:symbol-prefix" -v "widgets_collapsible_paned" \
    -a '//_:class[@name="WidgetsCompositedWindow"]' -t "attr" -n "c:symbol-prefix" -v "widgets_composited_window" \
    -a '//_:class[@name="WidgetsDatePicker"]' -t "attr" -n "c:symbol-prefix" -v "widgets_date_picker" \
    -a '//_:class[@name="WidgetsTab"]' -t "attr" -n "c:symbol-prefix" -v "widgets_tab" \
    -a '//_:class[@name="WidgetsDynamicNotebook"]' -t "attr" -n "c:symbol-prefix" -v "widgets_dynamic_notebook" \
    -a '//_:class[@name="WidgetsDynamicNotebookTabBehavior"]' -t "attr" -n "c:symbol-prefix" -v "widgets_dynamic_notebook_tab_behavior" \
    -a '//_:class[@name="WidgetsModeButton"]' -t "attr" -n "c:symbol-prefix" -v "widgets_mode_button" \
    -a '//_:class[@name="WidgetsOverlayBar"]' -t "attr" -n "c:symbol-prefix" -v "widgets_overlay_bar" \
    -a '//_:class[@name="WidgetsSourceList"]' -t "attr" -n "c:symbol-prefix" -v "widgets_source_list" \
    -u '//_:class[@name="WidgetsSourceList"]/_:callback[@name="VisibleFunc"]/@name' -v "WidgetsSourceListVisibleFunc" \
    -m '//_:class[@name="WidgetsSourceList"]/_:callback[@name="WidgetsSourceListVisibleFunc"]' '//_:namespace[@name="Granite"]' \
    -a '//_:class[@name="WidgetsSourceListItem"]' -t "attr" -n "c:symbol-prefix" -v "widgets_source_list_item" \
    -a '//_:class[@name="WidgetsSourceListExpandableItem"]' -t "attr" -n "c:symbol-prefix" -v "widgets_source_list_expandable_item" \
    -a '//_:class[@name="WidgetsStorageBar"]' -t "attr" -n "c:symbol-prefix" -v "widgets_storage_bar" \
    -a '//_:class[@name="WidgetsTimePicker"]' -t "attr" -n "c:symbol-prefix" -v "widgets_time_picker" \
    -a '//_:class[@name="WidgetsToast"]' -t "attr" -n "c:symbol-prefix" -v "widgets_toast" \
    -a '//_:class[@name="WidgetsWelcomeButton"]' -t "attr" -n "c:symbol-prefix" -v "widgets_welcome_button" \
    -a '//_:class[@name="WidgetsWelcome"]' -t "attr" -n "c:symbol-prefix" -v "widgets_welcome" \
    -a '//_:class[@name="Application"]' -t "attr" -n "c:symbol-prefix" -v "application" \
    -u '//_:class[@name="Application"]/_:constant[@name="options"]/@name' -v "APPLICATION_options" \
    -m '//_:class[@name="Application"]/_:constant[@name="APPLICATION_options"]' '//_:namespace[@name="Granite"]' \
    -a '//_:interface[@name="WidgetsSourceListSortable"]' -t "attr" -n "c:symbol-prefix" -v "widgets_source_list_sortable" \
    -a '//_:interface[@name="WidgetsSourceListDragSource"]' -t "attr" -n "c:symbol-prefix" -v "widgets_source_list_drag_source" \
    -a '//_:interface[@name="WidgetsSourceListDragDest"]' -t "attr" -n "c:symbol-prefix" -v "widgets_source_list_drag_dest" \
    -d '////_:type[@name="Gee.Collection"]/*' \
    -a '//_:class[@name="SettingsPage"]' -t "attr" -n "c:symbol-prefix" -v "settings_page" \
    -a '//_:class[@name="SimpleSettingsPage"]' -t "attr" -n "c:symbol-prefix" -v "simple_settings_page" \
    -a '//_:class[@name="AccelLabel"]' -t "attr" -n "c:symbol-prefix" -v "accel_label" \
    -a '//_:class[@name="AsyncImage"]' -t "attr" -n "c:symbol-prefix" -v "async_image" \
    -a '//_:class[@name="HeaderLabel"]' -t "attr" -n "c:symbol-prefix" -v "header_label" \
    -a '//_:class[@name="MessageDialog"]' -t "attr" -n "c:symbol-prefix" -v "message_dialog" \
    -a '//_:class[@name="ModeSwitch"]' -t "attr" -n "c:symbol-prefix" -v "mode_switch" \
    -a '//_:class[@name="SeekBar"]' -t "attr" -n "c:symbol-prefix" -v "seek_bar" \
    -a '//_:class[@name="Settings"]' -t "attr" -n "c:symbol-prefix" -v "settings" \
    -a '//_:class[@name="SettingsSidebar"]' -t "attr" -n "c:symbol-prefix" -v "settings_sidebar" \
    -u '////_:return-value/_:type[@name="Granite.GraniteServicesContractorProxy"]/@name' -v "Granite.ServicesContractorProxy" \
    -u '////_:callback/_:parameters/_:parameter/_:type[@name="Granite.GraniteServicesContract"]/@name' -v "Granite.ServicesContract" \
    -u '//_:field/_:type[@name="Granite.GraniteServicesIconFactory"]/@name' -v "Granite.ServicesIconFactory" \
    -u '////_:return-value/_:type[@name="Granite.GraniteServicesIconFactory"]/@name' -v "Granite.ServicesIconFactory" \
    -u '////_:return-value/_:type[@name="Granite.GraniteServicesLogLevel"]/@name' -v "Granite.ServicesLogLevel" \
    -u '////_:parameters/_:parameter/_:type[@name="Granite.GraniteServicesLogLevel"]/@name' -v "Granite.ServicesLogLevel" \
    -u '////_:return-value/_:type[@name="Granite.GraniteServicesLogger"]/@name' -v "Granite.ServicesLogger" \
    -u '////_:return-value/_:type[@name="Granite.GraniteServicesPaths"]/@name' -v "Granite.ServicesPaths" \
    -u '////_:callback/_:parameters/_:parameter/_:type[@name="Granite.GraniteServicesSettings"]/@name' -v "Granite.ServicesSettings" \
    -u '///_:implements[@name="Granite.GraniteServicesSettingsSerializable"]/@name' -v "Granite.ServicesSettingsSerializable" \
    -u '////_:callback/_:parameters/_:parameter/_:type[@name="Granite.GraniteServicesSettingsSerializable"]/@name' -v "Granite.ServicesSettingsSerializable" \
    -u '////_:return-value/_:type[@name="Granite.GraniteServicesSimpleCommand"]/@name' -v "Granite.ServicesSimpleCommand" \
    -u '////_:return-value/_:type[@name="Granite.GraniteServicesSystem"]/@name' -v "Granite.ServicesSystem" \
    -u '//_:function[@name="widgets_show_about_dialog"]/_:parameters/_:parameter[@name="parent"]/_:type/@name' -v "Gtk.Window" \
    -u '//_:enumeration[@name="WidgetsStorageBarItemDescription"]/_:member[@name="files"]/@value' -v "0" \
    Granite-1.0.gir
