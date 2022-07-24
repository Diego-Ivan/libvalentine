/* enums.vala
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
     * Whether {@link Valentine.Doc} should quote all elements of the CSV file, or if it should only write
     * quotes when it is strictly necessary.
     */
    [Version(since="0.1")]
    public enum WriteMode {
        /**
         * Mode that will quote all elements of the CSV file
         */
        ALL_QUOTED,
        /**
         * Mode that will only quote strictly necessary elements
         *
         * Including strings that contain the separator
         */
        ONLY_REQUIRED_QUOTES;

        public string parse_string (string str, string separator) {
            switch (this) {
                case ONLY_REQUIRED_QUOTES:
                    string s = str.replace ("\"", "\"\"");
                    if (s.contains (separator)) {
                        return "\"%s\"".printf (s);
                    }
                    return s;

                case ALL_QUOTED:
                    string s = str.replace ("\"", "\"\"");
                    return "\"%s\"".printf (s);

                default:
                    critical ("WriteMode defaulted, returning empty string");
                    return "";
            }
        }
    }

    [Version(since="0.1")]
    public enum SeparatorMode {
        PREFER_LOCALE,
        USE_COMMAS,
        USE_DOTS;

        internal string get_separator () {
            switch (this) {
                // case PREFER_LOCALE:
                //     return _(",");

                case USE_DOTS:
                    return ".";

                case USE_COMMAS:
                default:
                    // In case of a default, we will default to a comma
                    return ",";
            }
        }
    }

    /**
     * Thrown by {@link Valentine.ObjectWriter}
     */
    [Version(since="0.1")]
    public errordomain ObjectWriterError {
        /**
         * Indicates that the {@link GLib.Type} given to {@link Valentine.ObjectWriter} is not an Object
         */
        NOT_OBJECT
    }
}
