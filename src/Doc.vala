/* Doc.vala
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

namespace Valentine {
    /**
     * A CSV writer based on {@link GLib.Object} information
     *
     * This class that will generate the CSV file based on the information provided
     * by the {@link GLib.ParamSpec} given by the objects that you give to #this
     *
     * Currently, the parsing methods are can exclusively work using Object arrays, which is quite
     * incovenient as it is prone to errors. It is very likely that in the future, this structure
     * will implement a {@link GLib.ListModel} to store Objects.
     */
    public sealed class Doc : Object {
        private CustomType[] custom_types = {};

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

        /**
         * Add a parser for a type that is not processed by default.
         *
         * This method allows users to add a function that parses types that can't be parsed by default, such
         * as structs, classes or other objects.
         *
         * ''Example''<<BR>>
         * {{{
         *  public class MyObject : Object {
         *      public Person person { get; set; }
         *      public bool hired { get; set; default = true; }
         *  }
         *
         *  // Custom Type that can't be parsed by default
         *  public struct Person {
         *      public string name;
         *      public int age;
         *  }
         * public static int main () {
         *      Person[] people = {
         *          { "Diego", 17 },
         *          { "George", 20 },
         *          { "Lucas", 29 },
         *          { "Daniela", 18 },
         *          { "Luna", 25 }
         *      };
         *
         *      MyObject[] objects = {};
         *      foreach (var person in people) {
         *          objects += new MyObject () {
         *              person = person
         *          };
         *      }
         *
         *      var doc = new Valentine.Doc ();
         *      doc.add_custom_func_for_type (typeof(Person), (val) => {
         *        var person = (Person) val;
         *        return "%s:%i".printf (person.name, person.age);
         *      });
         *
         *      stdout.printf (doc.build_from_array ((Object[]) objects));
         *      return 0;
         *
         * }
         * }}}
         *
         * @param t The object {@link GLib.Type} that will be given a custom parser
         * @param f The {@link Valentine.UserConversionFunc} that will parse the value given
         */
        public void add_custom_func_for_type (Type t, UserConversionFunc f) {
            custom_types += CustomType () {
                type = t,
                func = f
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
}
