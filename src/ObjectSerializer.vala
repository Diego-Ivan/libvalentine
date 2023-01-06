/* ObjectSerializer.vala
 *
 * Copyright 2022-2023 Diego Iván <diegoivan.mae@gmail.com>
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
    private List<Object> object_list = new List<Object> ();

    internal HashTable<string, Property> properties { get; set; default = new HashTable<string, Property> (str_hash, str_equal); }
    internal HashTable<Type, ParserType> parser_types { get; set; default = new HashTable<Type, ParserType> (int_hash, int_equal); }

    /**
     * Constructs a new {@link ObjectSerializer} with the Type given
     *
     * For this implementation, the type must be a {@link GLib.Object} or a derivate.
     */
    public ObjectSerializer () requires (typeof(T).is_object ()) {
        Type obj_type = typeof (T);

        var klass = (ObjectClass) obj_type.class_ref ();
        foreach (ParamSpec spec in klass.list_properties ()) {
            if (READABLE in spec.flags) {
                properties[spec.name] = new Property () {
                    name = spec.name,
                    type = spec.value_type
                };
            }
        }
    }

    static construct {
        init ();
    }

    construct {
        parser_types[typeof(string)] = new SerializableType (value_string_to_string);
        parser_types[typeof(int)] = new SerializableType (value_int_to_string);
        parser_types[typeof(uint)] = new SerializableType (value_int_to_string);
        parser_types[typeof(float)] = new SerializableType (value_int_to_string);
        parser_types[typeof(double)] = new SerializableType (value_int_to_string);
        parser_types[typeof(long)] = new SerializableType (value_int_to_string);
        parser_types[typeof(ulong)] = new SerializableType (value_int_to_string);
        parser_types[typeof(bool)] = new SerializableType (value_int_to_string);
        parser_types[typeof(char)] = new SerializableType (value_int_to_string);
        parser_types[typeof(uchar)] = new SerializableType (value_int_to_string);
        parser_types[typeof(string[])] = new SerializableType (value_int_to_string);
        parser_types[typeof(Variant)] = new SerializableType (value_int_to_string);
        parser_types[typeof(File)] = new SerializableType (value_int_to_string);
        parser_types[typeof(DateTime)] = new SerializableType (value_int_to_string);
    }

    /**
     * Adds a new Object to #this
     *
     * This object will be processed later to create the CSV file based on the type information
     */
    [Version (since="0.2.5")]
    public void add_object (T obj) requires (typeof(T).is_object ()) {
        object_list.append ((Object) obj);
    }

    /**
     * {@inheritDoc}
     */
    [Version (since="0.2.5")]
    public override string to_string () requires (typeof(T).is_object ()) {
        string separator = separator_mode.get_separator ();
        string output = "";
        remove_unparsable_properties ();

        for (List<unowned Property>? list = properties.get_values (); list != null; list = list.next) {
            // Here we check if it is the lat one of the list, so we stop writing separators.
            // list.data is a Valentine.Property
            if (list.next == null) {
                output += "%s\n".printf (list.data.name);
                continue;
            }

            output += "%s%s".printf (list.data.name, separator);
        }

        try {
            int length = (int) object_list.length ();
            var communication = new AsyncQueue<SerializerLine> ();

            var processsing_thread_pool = new ThreadPool<SerializerLine>.with_owned_data ((serializer_line) => {
                serializer_line.serialize (properties, (HashTable<Type, SerializableType>) parser_types);
                communication.push_sorted (serializer_line, lines_sort_func);
            }, 8, false);

            int i = 0;
            foreach (var object in object_list) {
                processsing_thread_pool.add (new SerializerLine (object, separator, write_mode, i));
                i++;
            }

            while (communication.length () != length);

            for (int j = 0; j < length; j++) {
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
     * that are registered as properties.
     *
     * @param type The type that will be processed
     * @param func The function that processes the type
     */
    [Version (since="0.2.5")]
    public void add_custom_parser_for_type (Type type, owned TypeSerializationFunc func) requires (typeof(T).is_object ()) {
        parser_types[type] = new SerializableType ((owned) func);
    }

    private int lines_sort_func (SerializerLine a, SerializerLine b) {
        return a.position - b.position;
    }
}
