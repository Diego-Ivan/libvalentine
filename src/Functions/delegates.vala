/* delegates.vala
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
     * TypeSerializationFunc allows to parse types that cannot be automatically parsed by Valentine.
     *
     * The function gives a {@link GLib.Value} and expects that a string is returned. This strings must be
     * given by the developer at the end of the processing process
     *
     * @param val a {@link GLib.Value} that holds the custom type that should be processed into a string
     * @return The string that will be written into the CSV file
     */
    [Version (since="0.1")]
    public delegate string TypeSerializationFunc (Value val);

    /**
     * TypeDeserializationFunc allows to convert a cell from a CSV string to a {@link GLib.Value}
     *
     * This function takes a string and is expected to be converted to {@link GLib.Value} that {@link ObjectDeserializer}
     * can use to set an object property with some type.
     *
     * @param str The CSV cell that has to be deserialized. Note that this string is no longer quoted. It may
     * contain quotes if they were inside the string extracted from a CSV file or string.
     * @return A {@link GLib.Value}
     */
    [Version (since="0.2")]
    public delegate Value TypeDeserializationFunc (string str);
}
