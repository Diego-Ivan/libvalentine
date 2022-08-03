/* SerializerLine.vala
 *
 * Copyright $year Diego Iván <diegoivan.mae@gmail.com>
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

internal class Valentine.SerializerLine<T> : Object {
    public Object object { get; construct; }
    public string separator { get; construct; }
    public WriteMode write_mode { get; construct; }
    public int position { get; construct; }

    public string result { get; private set; default = ""; }

    public SerializerLine (Object obj, string s, WriteMode mode, int pos) {
        Object (
            object: obj,
            separator: s,
            write_mode: mode,
            position: pos
        );
    }

    public void serialize (Gee.LinkedList<Property?> serializable_properties, Gee.LinkedList<ParsableType?> serializable_types) {
        for (int i = 0; i < serializable_properties.size; i++) {
            Property property = serializable_properties.get (i);
            Value val = Value (property.type);

            object.get_property (property.name, ref val);

            bool found = false;
            string s = "";
            foreach (ParsableType type in serializable_types) {
                if (type.type == property.type) {
                    s = type.func (val);
                    found = true;

                    string str = write_mode.parse_string (s, separator);
                    if (serializable_properties.size - 1 == i) {
                        str += "\n";
                    }
                    else {
                        str += "%s".printf (separator);
                    }

                    result += str;
                    break;
                }
            }

            if (!found) {
                if (val.type ().is_flags ()) {
                    s = Parser.value_flags_to_string (val);
                    string str = write_mode.parse_string (s, separator);
                    if (serializable_properties.size - 1 == i) {
                        str += "\n";
                    }
                    else {
                        str += "%s".printf (separator);
                    }

                    result += str;
                    continue;
                }

                if (val.type ().is_enum ()) {
                    s = Parser.value_enum_to_string (val);
                    string str = write_mode.parse_string (s, separator);
                    if (serializable_properties.size - 1 == i) {
                        str += "\n";
                    }
                    else {
                        str += "%s".printf (separator);
                    }

                    result += str;
                    continue;
                }
            }
        }
    }
}