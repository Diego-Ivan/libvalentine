/* Doc.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

namespace Valentine {
    public sealed class Doc : Object {
        private struct Property {
            public string name;
            public Type type;
        }

        public Doc () {
        }

        public string build_from_array (Object[] array) requires (array.length > 0) {
            Type type = (array[0]).get_type ();
            ObjectClass klass = (ObjectClass) type.class_ref ();

            Property[] readable_properties = {};
            foreach (ParamSpec spec in klass.list_properties ()) {
                if (READABLE in spec.flags) {
                    var property = Property () {
                        name = spec.name,
                        type = spec.value_type
                    };
                    readable_properties += property;
                }
            }

            string format = "";
            // Creating the headers for the properties
            for (int i = 0; i < readable_properties.length; i++) {
                // Here we check if it is the last one of the array to stop writing separators, and instead
                // use a line break
                if (i == readable_properties.length - 1) {
                    format += "%s\n".printf (readable_properties[i].name);
                    continue;
                }
                format += "%s,".printf (readable_properties[i].name);
            }

            // Now, we we'll start to write the properties per object
            foreach (Object obj in array) {
                for (int i = 0; i < readable_properties.length; i++) {
                    Property property = readable_properties[i];
                    Value val = Value (property.type);
                    obj.get_property (property.name, ref val);

                    string str;
                    if (!value_to_string (val, out str)) {
                        warning ("Property %s could not be parsed", property.name);
                        continue;
                    }

                    if (i == readable_properties.length - 1) {
                        format += "\"%s\"\n".printf (str);
                        continue;
                    }

                    format += "\"%s\",".printf (str);
                }
            }

            return format;
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

                case Type.BOOLEAN:
                    result = ((bool) val).to_string ();
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

                    result = "";
                    return false;
            }
        }
    }
}
