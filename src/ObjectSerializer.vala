/* ObjectSerializer.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * This file is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 3 of the
 * License, or (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

/**
 * An {@link AbstractWriter} implementation that converts {@link GLib.Object}s into a CSV file
 *
 * This class that will generate the CSV file based on the information provided by the {@link GLib.ParamSpec}
 * given by the object type given to #this
 *
 */
[Version (since="0.2.5", experimental=true, experimental_until="0.3")]
public sealed class Valentine.ObjectSerializer<T> : Valentine.AbstractWriter, Valentine.TypeParser {
    private Valentine.Property[] readable_properties = {};
    private List<Object> object_list = new List<Object> ();

    private Gee.LinkedList<SerializableType> parsable_types = new Gee.LinkedList<SerializableType> ();

    /**
     * Constructs a new {@link ObjectSerializer} with the Type given
     *
     * For this implementation, the type must be a {@link GLib.Object} or a derivate. Otherwise, it will
     * throw an Error
     */
    public ObjectSerializer () throws Error {
        Type obj_type = typeof (T);
        if (!obj_type.is_object ()) {
            throw new ObjectWriterError.NOT_OBJECT ("Type given is not an Object");
        }

        ObjectClass klass = (ObjectClass) obj_type.class_ref ();
        foreach (ParamSpec spec in klass.list_properties ()) {
            if (READABLE in spec.flags) {
                readable_properties += Valentine.Property () {
                    name = spec.name,
                    type = spec.value_type
                };
            }
        }
    }

    construct {
        parsable_types.add (new SerializableType (typeof (string), Parser.value_string_to_string));
        parsable_types.add (new SerializableType (typeof (int), Parser.value_int_to_string));
        parsable_types.add (new SerializableType (typeof (uint), Parser.value_uint_to_string));
        parsable_types.add (new SerializableType (typeof (float), Parser.value_float_to_string));
        parsable_types.add (new SerializableType (typeof (double), Parser.value_double_to_string));
        parsable_types.add (new SerializableType (typeof (long), Parser.value_long_to_string));
        parsable_types.add (new SerializableType (typeof (ulong), Parser.value_ulong_to_string));
        parsable_types.add (new SerializableType (typeof (bool), Parser.value_boolean_to_string));
        parsable_types.add (new SerializableType (typeof (char), Parser.value_char_to_string));
        parsable_types.add (new SerializableType (typeof (uchar), Parser.value_uchar_to_string));
        parsable_types.add (new SerializableType (typeof (string[]), Parser.value_string_array_to_string));
        parsable_types.add (new SerializableType (typeof (Variant), Parser.value_variant_to_string));
        parsable_types.add (new SerializableType (typeof (File), Parser.value_file_to_string));
        parsable_types.add (new SerializableType (typeof (DateTime), Parser.value_datetime_to_string));
    }

    /**
     * Adds a new Object to #this
     *
     * This object will be processed later to create the CSV file based on the type information
     */
    [Version (since="0.2.5")]
    public void add_object (T obj) {
        object_list.append ((Object) obj);
    }

    [Version (since="0.2.5")]
    public override string to_string () {
        Gee.LinkedList<Property?> parsable_properties = new Gee.LinkedList<Property?> ();
        // First, we will discard properties that are not parsable
        foreach (Property property in readable_properties) {
            if (supports_type (property.type)) {
                parsable_properties.add (property);
                continue;
            }

            debug ("A parser for property type %s was not found", property.type.name ());
        }

        string separator = separator_mode.get_separator ();
        string output = "";

        // First, the column titles will be written with the property names that were obtained
        for (int i = 0; i < parsable_properties.size; i++) {
            // Here we check if it is the last one of the array to stop writing separators, and instead
            // use a line break
            if (i == parsable_properties.size - 1) {
                output += "%s\n".printf (parsable_properties.get (i).name);
                continue;
            }
            output += "%s%s".printf (parsable_properties.get (i).name, separator);
        }

        try {
            int length = (int) object_list.length ();
            var communication = new AsyncQueue<SerializerLine> ();

            var processsing_thread_pool = new ThreadPool<SerializerLine>.with_owned_data ((serializer_line) => {
                serializer_line.serialize (parsable_properties, parsable_types);
                communication.push_sorted (serializer_line, lines_sort_func);
            }, 8, false);

            for (int i = 0; i < length; i++) {
                processsing_thread_pool.add (new SerializerLine<T> (object_list.nth_data (i), separator, write_mode, i));
            }

            while (communication.length () != length);

            for (int i = 0; i < length; i++) {
                output += communication.pop ().result;
            }
        }
        catch (Error e) {
            critical (e.message);
        }

        return output;
    }

    /**
     * Adds a parser function for types that aren't processed by default
     *
     * This function allows the user to add parse unsupported types like structs, classes or objects
     * that are properties.
     *
     * @param type The type that will be processed
     * @param func The function that processes the type
     */
    [Version (since="0.2.5")]
    public void add_custom_parser_for_type (Type type, TypeSerializationFunc func) {
        parsable_types.add (new SerializableType (type, func));
    }

    public bool supports_type (Type type) {
        foreach (SerializableType t in parsable_types) {
            if (t.type == type) {
                return true;
            }
        }
        return type.is_enum () || type.is_flags ();
    }

    private int lines_sort_func (SerializerLine a, SerializerLine b) {
        return a.position - b.position;
    }
}
