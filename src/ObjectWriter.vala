/* ObjectWriter.vala
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
 * A {@link Valentine.AbstractWriter} implementation that converts {@link GLib.Object}s into a CSV file
 *
 * This class that will generate the CSV file based on the information provided by the {@link GLib.ParamSpec}
 * given by the object type given to #this
 *
 */
[Version (since="0.1")]
public sealed class Valentine.ObjectWriter<T> : Valentine.AbstractWriter {
    private Valentine.Property[] readable_properties = {};
    private Valentine.ParsableType[] custom_types = {};
    private List<T> object_list = new List<T> ();

    private Gee.LinkedList<ParsableType?> parsable_types = new Gee.LinkedList<ParsableType?> ();
    private Gee.LinkedList<Property?> parsable_properties = new Gee.LinkedList<Property?> ();

    /**
     * Constructs a new {@link Valentine.ObjectWriter} with the Type given
     *
     * For this implementation, the type must be a {@link GLib.Object} or a derivate. Otherwise, it will
     * throw an Error
     */
    public ObjectWriter () throws Error {
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
        parsable_types.add ( {typeof (string), Parser.value_string_to_string} );
        parsable_types.add ( {typeof (int), Parser.value_int_to_string} );
        parsable_types.add ( {typeof (uint), Parser.value_uint_to_string} );
        parsable_types.add ( {typeof (float), Parser.value_float_to_string} );
        parsable_types.add ( {typeof (double), Parser.value_double_to_string} );
        parsable_types.add ( {typeof (long), Parser.value_long_to_string} );
        parsable_types.add ( {typeof (ulong), Parser.value_ulong_to_string} );
        parsable_types.add ( {typeof (bool), Parser.value_boolean_to_string} );
        parsable_types.add ( {typeof (char), Parser.value_char_to_string} );
        parsable_types.add ( {typeof (uchar), Parser.value_uchar_to_string} );
        parsable_types.add ( {typeof (Variant), Parser.value_variant_to_string} );
        parsable_types.add ( {typeof (File), Parser.value_file_to_string} );
        parsable_types.add ( {typeof (DateTime), Parser.value_datetime_to_string} );
    }

    /**
     * Adds a new Object to #this
     *
     * This object will be processed later to create the CSV file based on the type information
     */
    [Version (since="0.1")]
    public void add_object (T obj) {
        object_list.append (obj);
    }

    [Version (since="0.1")]
    public override string to_string () {
        // First, we will discard properties that are not parsable
        foreach (Property property in readable_properties) {
            bool found = false;

            parsable_types.foreach ((type) => {
                if (property.type == type.type) {
                    found = true;
                    return false;
                }

                return true;
            });

            if (found || property.type.is_flags () || property.type.is_enum ()) {
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

        object_list.foreach ((item) => {
            Object obj = (Object) item;
            for (int i = 0; i < parsable_properties.size; i++) {
                Valentine.Property property = parsable_properties.get (i);

                Value val = Value (property.type);
                obj.get_property (property.name, ref val);

                string s = "";
                bool found = false;
                foreach (ParsableType type in parsable_types) {
                    if (type.type == val.type ()) {
                        s = type.func (val);
                        found = true;

                        string str = write_mode.parse_string (s, separator);
                        if (i == parsable_properties.size - 1) {
                            str += "\n";
                        }
                        else {
                            str += "%s".printf (separator);
                        }
                        output += str;

                        break;
                    }
                }

                if (!found) {
                    if (val.type ().is_flags ()) {
                        s = Parser.value_flags_to_string (val);
                        string str = write_mode.parse_string (s, separator);

                        if (i == parsable_properties.size - 1) {
                            str += "\n";
                        }
                        else {
                            str += "%s".printf (separator);
                        }

                        output += str;
                        continue;
                    }

                    if (val.type ().is_enum ()) {
                        s = Parser.value_enum_to_string (val);
                        string str = write_mode.parse_string (s, separator);

                        if (i == parsable_properties.size - 1) {
                            str += "\n";
                        }
                        else {
                            str += "%s".printf (separator);
                        }

                        output += str;
                        continue;
                    }
                }
            }
        });

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
    [Version (since="0.1")]
    public void add_custom_parser_for_type (Type type, UserConversionFunc func) {
        parsable_types.add ({type, func});
    }

    private bool value_to_string (Value val, out string result) {
        switch (val.type ()) {
            case Type.STRING:
                result = (string) val;
                return true;

            case Type.INT:
                result = ((int) val).to_string ();
                return true;

            case Type.UINT:
                result = ((uint) val).to_string ();
                return true;

            case Type.FLOAT:
                result = ((float) val).to_string ();
                return true;

            case Type.DOUBLE:
                result = ((double) val).to_string ();
                return true;

            case Type.LONG:
                result = ((long) val).to_string ();
                return true;

            case Type.ULONG:
                result = ((ulong) val).to_string ();
                return true;

            case Type.BOOLEAN:
                result = ((bool) val).to_string ();
                return true;

            case Type.CHAR:
                result = ((char) val).to_string ();
                return true;

            case Type.UCHAR:
                result = ((uchar) val).to_string ();
                return true;

            case Type.VARIANT:
                Variant variant = (Variant) val;
                if (variant == null) {
                    result = "(null)";
                }
                else {
                    result = variant.print (false);
                }
                return true;

            default:
                // Check if the type holds flags
                if (val.type ().is_flags ()) {
                    uint flags_value = val.get_flags ();
                    result = FlagsClass.to_string (val.type (), flags_value);
                    return true;
                }

                // Check if the types holds an enum
                if (val.type ().is_enum ()) {
                    int enum_value = val.get_enum ();
                    result = EnumClass.to_string (val.type (), enum_value);
                    return true;
                }

                if (val.holds (typeof(File))) {
                    var file = (File) val;
                    if (file != null) {
                        result = file.get_path ();
                    }
                    else {
                        result = "(null)";
                    }

                    return true;
                }

                if (val.holds (typeof(DateTime))) {
                    var date_time = (DateTime) val;
                    if (date_time == null) {
                        result = "(null)";
                    }
                    else {
                        result = date_time.format ("%c");
                    }

                    return true;
                }

                foreach (ParsableType t in custom_types) {
                    if (val.holds (t.type)) {
                        result = t.func (val);
                        return true;
                    }
                }

                result = "";
                return false;
        }
    }
}
