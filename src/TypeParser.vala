/* TypeParser.vala
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

[Version (since="0.2")]
public interface Valentine.TypeParser : Object {
    internal abstract Gee.LinkedList<Property?> properties { get; set; default = new Gee.LinkedList<Property?> (); }
    internal abstract Gee.LinkedList<ParserType> parser_types { get; set; default = new Gee.LinkedList<ParserType> (); }

    internal virtual Gee.ArrayList<Property?> get_parsable_properties () {
        var parsable_types = new Gee.ArrayList<Property?> ();
        foreach (Property property in properties) {
            if (supports_type (property.type)) {
                parsable_types.add (property);
                continue;
            }
        }

        return parsable_types;
    }

    public virtual bool supports_type (Type type) {
        foreach (ParserType t in parser_types) {
            if (t.type == type) {
                return true;
            }
        }
        return type.is_enum () || type.is_flags ();
    }
}
