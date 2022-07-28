/* Parser.vala
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

namespace Valentine.Parser {
    internal inline string value_string_to_string (Value val) {
        string str = (string) val;
        if (str == null) {
            return "(null)";
        }

        return str;
    }

    internal inline string value_int_to_string (Value val) {
        return ((int) val).to_string ();
    }

    internal inline string value_uint_to_string (Value val) {
        return ((uint) val).to_string ();
    }

    internal inline string value_float_to_string (Value val) {
        return ((float) val).to_string ();
    }

    internal inline string value_double_to_string (Value val) {
        return ((double) val).to_string ();
    }

    internal inline string value_long_to_string (Value val) {
        return ((long) val).to_string ();
    }

    internal inline string value_ulong_to_string (Value val) {
        return ((ulong) val).to_string ();
    }

    internal inline string value_boolean_to_string (Value val) {
        return ((bool) val).to_string ();
    }

    internal inline string value_char_to_string (Value val) {
        return ((char) val).to_string ();
    }

    internal inline string value_uchar_to_string (Value val) {
        return ((uchar) val).to_string ();
    }

    internal inline string value_variant_to_string (Value val) {
        Variant variant = (Variant) val;
        if (variant == null) {
            return "(null)";
        }

        return variant.print (false);
    }

    internal inline string value_flags_to_string (Value val) {
        uint flags_value = val.get_flags ();
        return FlagsClass.to_string (val.type (), flags_value);
    }

    internal inline string value_enum_to_string (Value val) {
        int enum_value = val.get_enum ();
        return EnumClass.to_string (val.type (), enum_value);
    }

    internal inline string value_datetime_to_string (Value val) {
        DateTime dt = (DateTime) val;
        if (dt == null) {
            return "(null)";
        }

        return dt.format ("%c");
    }

    internal inline string value_file_to_string (Value val) {
        File file = (File) val;
        if (file == null) {
            return "(null)";
        }

        return file.get_path ();
    }
}
