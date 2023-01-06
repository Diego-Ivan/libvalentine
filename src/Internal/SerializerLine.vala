/* SerializerLine.vala
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

internal sealed class Valentine.SerializerLine : Valentine.AbstractLine<string> {
    public Object object { get; private set; }
    public string separator { get; private set; }
    public WriteMode write_mode { get; private set; }
    public override string result { get; protected set; default = ""; }

    public SerializerLine (Object obj, string s, WriteMode mode, int pos) {
        object = obj;
        separator = s;
        write_mode = mode;
        position = pos;
    }

    public void serialize (HashTable<string, Property> properties, HashTable<Type, SerializableType> serializable_types) {
        for (List<unowned Property>? list = properties.get_values (); list != null; list = list.next) {
            unowned Property property = list.data;
            var @value = Value (property.type);

            object.get_property (property.name, ref @value);

            SerializableType? type = serializable_types[property.type];
            unowned TypeSerializationFunc? serialization_func = null;

            if (type == null) {
                serialization_func = get_default_func (property.type);
            }
            else {
                serialization_func = type.func;
            }

            result = write_mode.parse_string (serialization_func (value), separator);
            // Write separator if it's not the last property.
            result += "%s".printf (list.next == null ? "\n" : separator);
        }
    }

    public unowned TypeSerializationFunc get_default_func (Type type) {
        if (type.is_enum ()) {
            return value_enum_to_string;
        }
        return value_flags_to_string;
    }
}
