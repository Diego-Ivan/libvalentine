/* ObjectDeserializer.vala
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
 * A class that deserializes objects from a CSV file given.
 *
 * This class receives the path of the CSV file and returns an array of Objects with the properties
 * defined in the CSV file. It is recommended that this object is used to parse CSV strings or files generated
 * by {@link ObjectSerializer}
 */
[Version (since="0.2", experimental=true, experimental_until="0.3")]
public sealed class Valentine.ObjectDeserializer<T> : Object, Valentine.TypeParser {
    internal Gee.LinkedList<Property?> properties { get; set; default = new Gee.LinkedList<Property?> (); }
    internal Gee.LinkedList<ParserType> parser_types { get; set; default = new Gee.LinkedList<DeserializableType> (); }

    public ObjectDeserializer () requires (typeof(T).is_object ()) {
        Type type = typeof (T);

        ObjectClass klass = (ObjectClass) type.class_ref ();
        foreach (ParamSpec spec in klass.list_properties ()) {
            if (WRITABLE in spec.flags && !(CONSTRUCT_ONLY in spec.flags)) {
                properties.add (new Property () {
                    name = spec.name,
                    type = spec.value_type
                });
            }
        }
    }

    construct {
        parser_types.add (new DeserializableType (typeof (int), value_int_from_string));
        parser_types.add (new DeserializableType (typeof (uint), value_uint_from_string));
        parser_types.add (new DeserializableType (typeof (float), value_float_from_string));
        parser_types.add (new DeserializableType (typeof (double), value_double_from_string));
        parser_types.add (new DeserializableType (typeof (bool), value_boolean_from_string));
        parser_types.add (new DeserializableType (typeof (string), value_string_from_string));
        parser_types.add (new DeserializableType (typeof (string[]), value_string_array_from_string));
        parser_types.add (new DeserializableType (typeof (long), value_long_from_string));
        parser_types.add (new DeserializableType (typeof (ulong), value_ulong_from_string));
        parser_types.add (new DeserializableType (typeof (uchar), value_uchar_from_string));
        parser_types.add (new DeserializableType (typeof (char), value_char_from_string));
        parser_types.add (new DeserializableType (typeof (unichar), value_unichar_from_string));
        parser_types.add (new DeserializableType (typeof (Variant), value_variant_from_string));
        parser_types.add (new DeserializableType (typeof (DateTime), value_datetime_from_string));
        parser_types.add (new DeserializableType (typeof (File), value_file_from_string));
    }

    /**
     * The method that executes the deserialization from a given file.
     *
     * This method parses the file and creates objects with the properties defined in the CSV file.
     *
     * @param path The path to the CSV file
     * @return A list of objects
     */
    public List<T> deserialize_from_file (string path) requires (typeof(T).is_object ()) {
        File file = File.new_for_path (path);
        if (!file.query_exists ()) {
            critical ("File does not exist!");
            return new List<T> ();
        }

        try {
            FileInfo info = file.query_info ("standard::*", NOFOLLOW_SYMLINKS);
            if (info.get_content_type () != "text/csv") {
                critical ("File %s is not a CSV file", path);
            }
        }
        catch (Error e) {
            error (e.message);
        }

        try {
            FileInputStream stream = file.read ();
            DataInputStream dis = new DataInputStream (stream);

            // Reading Columns
            string line = dis.read_line ();
            var column_array = new Gee.ArrayList<string>.wrap (line.split (","));

            int l = 0; // Line counter
            DeserializerLine<T>[] lines = {};
            while ((line = dis.read_line ()) != null) {
                l++;
                lines += new DeserializerLine<T> (line, l);
            }
            dis.close ();
            var queue = new AsyncQueue<DeserializerLine<T>> ();
            ThreadPool<DeserializerLine<T>> thread_pool = new ThreadPool<DeserializerLine<T>>.with_owned_data ((line_deserializer) => {
                line_deserializer.deserialize_line (column_array, get_parsable_properties (), (Gee.LinkedList<DeserializableType>) parser_types);
                queue.push_sorted (line_deserializer, object_sort_func);
            }, 6, false);

            for (int i = 0; i < lines.length; i++) {
                thread_pool.add (lines[i]);
            }

            while (queue.length () != l);

            var list = new List<T> ();
            for (int i= 0; i < l; i++) {
                list.append (queue.pop ().result);
            }

            return list;
        }
        catch (Error e) {
            error (e.message);
        }
    }

    /**
     * This method deserializes a valid CSV formatted string and returns a List of objects of the given type
     *
     * @param str The CSV string to parse
     * @return A list of objects of the given type
     */
    public List<T> deserialize_from_string (string str) requires (typeof(T).is_object ()) {
        var list = new List<T> ();

        string[] lines = str.split ("\n");
        var columns = new Gee.ArrayList<string>.wrap (lines[0].split(","));
        string[] elements = lines[1:lines.length - 1];
        int length = elements.length;

        DeserializerLine<T>[] deserializer_lines = {};
        for (int i = 0; i < length; i++) {
            deserializer_lines += new DeserializerLine<T> (elements[i], i+1);
        }

        try {
            var queue = new AsyncQueue<DeserializerLine<T>> ();
            var thread_pool = new ThreadPool<DeserializerLine<T>>.with_owned_data ((line_deserializer) => {
                line_deserializer.deserialize_line (columns, get_parsable_properties (), (Gee.LinkedList<DeserializableType>) parser_types);
                queue.push_sorted (line_deserializer, object_sort_func);
            }, 6, false);

            for (int i = 0; i < elements.length; i++) {
                thread_pool.add (deserializer_lines[i]);
            }

            while (queue.length () != length);

            for (int i = 0; i < length; i++) {
                list.append (queue.pop ().result);
            }
        }
        catch (Error e) {
            critical (e.message);
        }

        return list;
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
    public void add_custom_parser_for_type (Type type, owned TypeDeserializationFunc func) requires (typeof(T).is_object ()) {
        parser_types.add (new DeserializableType (type, (owned) func));
    }
    private int object_sort_func (DeserializerLine line_a, DeserializerLine line_b) {
        return line_a.position - line_b.position;
    }
}

