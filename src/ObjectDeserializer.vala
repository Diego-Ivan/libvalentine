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

        T[] array = {};

        FileInputStream stream = file.read ();
        DataInputStream dis = new DataInputStream (stream);

        string line = dis.read_line ();
        // Reading Columns
        string[] columns = line.split (",");

        int l = 0; // Line counter
        while ((line = dis.read_line ()) != null) {
            l++;
            string[] cells = {};
            string cell = "";

            for (int i = 0; i < line.length; i++) {
                unichar c = line.get_char (i);

                if (c == ',' && line.get_char (i+1) == '"' && (line.get_char (i+2) != '"' || line.get_char (i+3) == ',')) {
                    cells += parse_cell (cell);
                    cell = "";
                    continue;
                }
                else if (c == '"' && i == line.length - 1) {
                    cell += '"'.to_string ();
                    cells += parse_cell (cell);
                    cell = "";
                    continue;
                }
                cell += c.to_string ();
            }

            if (cells.length != columns.length) {
                debug ("Cells Length: %i. Columns Length: %i", cells.length, columns.length);
                warning ("Something went wrong parsing line %i, skipping...", l);
                continue;
            }

            Object obj = Object.new (typeof(T));
            for (int i = 0; i < cells.length; i++) {
                foreach (Property p in deserializable_properties) {
                    if (p.name == columns[i]) {

                        bool found = false;
                        deserializable_types.foreach ((t) => {
                            if (t.type == p.type) {
                                Value val = t.func (cells[i]);
                                obj.set_property (p.name, val);
                                found = true;

                                return false;
                            }
                            return true;
                        });

                        if (found) {
                            break;
                        }

                        if (p.type.is_enum ()) {
                            Value val = Deserializer.value_enum_from_string (cells[i], p.type);
                            obj.set_property (p.name, val);
                            break;
                        }

                        if (p.type.is_flags ()) {
                            Value val = Deserializer.value_flags_from_string (cells[i], p.type);
                            obj.set_property (p.name, val);
                            break;
                        }
                    }
                }
            }

            array += (T) obj;
        }

        dis.close ();

        return array;
    }

    private string parse_cell (string cell) {
        string result = cell;
        int quote_level = 0;
        for (int i = 0; i < cell.length; i++) {
            if (cell.get_char (i) == '"') {
                quote_level++;
            }
        }

        /*
         * Above we were looking for quotes, and the indentation level is how we have to replace quotes,
         * if the number is even, it means we have found the actual amount of open and close quote
         * matches, in case it's odd, it means we have found a single quote without a pair, and therefore
         * we'll remove it from the quote level
         *
         */
        if ((quote_level % 2) != 0) {
            quote_level--;
        }

        quote_level /= 2;

        string to_replace = "\"";
        string replacement = "";
        for (int i = 0; i < quote_level; i++) {
            result = result.replace (to_replace, replacement);
            to_replace += "\"";
            replacement += "\"";
        }

        return result;
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
