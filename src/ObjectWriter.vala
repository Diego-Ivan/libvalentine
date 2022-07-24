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
    private Valentine.CustomType[] custom_types = {};
    private List<T> object_list = new List<T> ();

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
        string separator = separator_mode.get_separator ();
        string output = "";

        // First, the column titles will be written with the property names that were obtained
        for (int i = 0; i < readable_properties.length; i++) {
            // Here we check if it is the last one of the array to stop writing separators, and instead
            // use a line break
            if (i == readable_properties.length - 1) {
                output += "%s\n".printf (readable_properties[i].name);
                continue;
            }
            output += "%s%s".printf (readable_properties[i].name, separator);
        }

        object_list.foreach ((item) => {
            Object obj = (Object) item;
            for (int i = 0; i < readable_properties.length; i++) {
                Valentine.Property property = readable_properties[i];

                Value val = Value (property.type);
                obj.get_property (property.name, ref val);

                string str;
                if (!value_to_string (val, out str)) {
                    warning ("Property %s could not be parsed", property.name);
                    continue;
                }

                if (i == readable_properties.length - 1) {
                    output += "\"%s\"\n".printf (str);
                    continue;
                }

                output += "\"%s\",".printf (str);
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
        custom_types += Valentine.CustomType () {
            type = type,
            func = func
        };
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

                foreach (CustomType t in custom_types) {
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
