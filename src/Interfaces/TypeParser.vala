/* TypeParser.vala
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

/**
 * An interface used for objects that can parse values.
 */
[Version (since="0.2")]
public interface Valentine.TypeParser : Object {
    internal abstract GenericSet<Property> properties { get; set; }
    internal abstract HashTable<Type, ParserType> parser_types { get; set; }

    internal virtual void remove_unparsable_properties () {
        foreach (unowned Property property in properties.get_values ()) {
            if (supports_type (property.type)) {
                properties.remove (property);
            }
        }
    }

    /**
     * Whether the type given has a parser available.
     *
     * @param type The type that will be looked for.
     * @return Whether it is supported or not.
     */
    public virtual bool supports_type (Type type) {
        return type in parser_types || type.is_enum () || type.is_flags ();
    }
}
