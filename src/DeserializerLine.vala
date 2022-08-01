/* DeserializerLine.vala
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

internal class Valentine.DeserializerLine<T> {
    public string line { get; private set; }
    public int line_number { get; private set; }
    public DeserializerLine (string l, int n_line) {
        line = l;
        line_number = n_line;
    }

    public T deserialize_line (ref string[] columns, ref Property[] deserializable_properties, Gee.LinkedList<DeserializableType?> deserializable_types) {
        Object obj = Object.new (typeof (T));
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
            warning ("Error found in line %i: Number of Elements in line (%i) do not match number of properties (%i)", line_number, cells.length, columns.length);
            return obj;
        }

        for (int i = 0; i < columns.length; i++) {
            foreach (Property property in deserializable_properties) {
                if (property.name == columns[i]) {
                    bool found = false;

                    foreach (DeserializableType t in deserializable_types) {
                        if (t.type == property.type) {
                            Value val = t.func (cells[i]);
                            obj.set_property (property.name, val);
                            found = true;
                            break;
                        }
                    }

                    if (found) {
                        break;
                    }

                    if (property.type.is_enum ()) {
                        Value val = Deserializer.value_enum_from_string (cells[i], property.type);
                        obj.set_property (property.name, val);
                        break;
                    }

                    if (property.type.is_flags ()) {
                        Value val = Deserializer.value_flags_from_string (cells[i], property.type);
                        obj.set_property (property.name, val);
                        break;
                    }
                }
            }
        }

        return (T) obj;
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
}
