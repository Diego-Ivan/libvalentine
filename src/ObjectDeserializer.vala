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
 * defined in the CSV file
 */
[Version (since="0.2", experimental=true, experimental_until="0.3")]
public sealed class Valentine.ObjectDeserializer<T> : Object, Valentine.TypeParser {
    private Valentine.Property[] writable_properties = {};
    private Gee.LinkedList<DeserializableType?> deserializable_types = new Gee.LinkedList<DeserializableType?> ();

    public ObjectDeserializer () throws Error {
        Type type = typeof (T);
        if (!type.is_object ()) {
            throw new ObjectWriterError.NOT_OBJECT ("The type given to the serializer is not an Object");
        }

        ObjectClass klass = (ObjectClass) type.class_ref ();
        foreach (ParamSpec spec in klass.list_properties ()) {
            if (WRITABLE in spec.flags) {
                writable_properties += Valentine.Property () {
                    name = spec.name,
                    type = spec.value_type
                };
            }
        }
    }

    construct {
        deserializable_types.add ({ typeof (int), Deserializer.value_int_from_string });
        deserializable_types.add ({ typeof (uint), Deserializer.value_uint_from_string });
        deserializable_types.add ({ typeof (float), Deserializer.value_float_from_string });
        deserializable_types.add ({ typeof (double), Deserializer.value_double_from_string });
        deserializable_types.add ({ typeof (bool), Deserializer.value_boolean_from_string });
        deserializable_types.add ({ typeof (string), Deserializer.value_string_from_string });
        deserializable_types.add ({ typeof (long), Deserializer.value_long_from_string });
        deserializable_types.add ({ typeof (ulong), Deserializer.value_ulong_from_string });
        deserializable_types.add ({ typeof (uchar), Deserializer.value_uchar_from_string } );
        deserializable_types.add ({ typeof (char), Deserializer.value_char_from_string });
        deserializable_types.add ({ typeof (unichar), Deserializer.value_unichar_from_string });
        deserializable_types.add ({typeof (Variant), Deserializer.value_variant_from_string });
        deserializable_types.add ({ typeof (DateTime), Deserializer.value_datetime_from_string });
        deserializable_types.add ({ typeof (File), Deserializer.value_file_from_string });
    }

    /**
     * The method that executes the deserialization from a given file.
     *
     * This method parses the file and creates objects with the properties defined in the CSV file.
     *
     * @param path The path to the CSV file
     * @return An array of objects
     */
    public T[] deserialize_from_file (string path) throws Error {
        File file = File.new_for_path (path);
        if (!file.query_exists ()) {
            throw new DeserializerError.FILE_NOT_EXISTS ("File for path %s does not exist", path);
        }

        FileInfo info = file.query_info ("standard::*", NOFOLLOW_SYMLINKS);
        if (info.get_content_type () != "text/csv") {
            throw new DeserializerError.FILE_NOT_CSV ("The file given is not a CSV file");
        }

        // Checking that we have deserializers for properties
        Valentine.Property[] deserializable_properties = {};
        foreach (Property p in writable_properties) {
            if (supports_type (p.type)) {
                deserializable_properties += p;
                continue;
            }
            debug ("Deserializer not available for property %s", p.name);
        }


        FileInputStream stream = file.read ();
        DataInputStream dis = new DataInputStream (stream);

        // Reading Columns
        string line = dis.read_line ();
        string[] columns = line.split (",");

        int l = 0; // Line counter
        DeserializerLine<T>[] lines = {};
        while ((line = dis.read_line ()) != null) {
            l++;
            lines += new DeserializerLine<T> (line, l);
        }
        dis.close ();

        Gee.ConcurrentList<T> t_list = new Gee.ConcurrentList<T> ();
        int completed = 0;
        ThreadPool<DeserializerLine<T>> thread_pool = new ThreadPool<DeserializerLine<T>>.with_owned_data ((line_deserializer) => {
            t_list.add (line_deserializer.deserialize_line (ref columns, ref deserializable_properties, deserializable_types));
            completed++;
        }, 4, false);

        for (int i = 0; i < lines.length; i++) {
            thread_pool.add (lines[i]);
        }

        while (completed != l) {
        }

        T[] array = {};
        foreach (T obj in t_list) {
            array += obj;
        }

        return array;
    }

    public void add_custom_parser_for_type (Type type, TypeDeserializationFunc func) {
        deserializable_types.add (Valentine.DeserializableType () {
            type = type,
            func = func
        });
    }

    public bool supports_type (Type type) {
        foreach (DeserializableType t in deserializable_types) {
            if (t.type == type) {
                return true;
            }
        }

        return false;
    }
}

