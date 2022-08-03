/* Deserializer.vala
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

namespace Valentine.Deserializer {
    internal inline Value value_int_from_string (string str) {
        Value val = Value (typeof(int));
        int result;
        if (int.try_parse (str, out result) || str != "(null)") {
            val = result;
        }
        return val;
    }

    internal inline Value value_boolean_from_string (string str) {
        Value val = Value (typeof (bool));
        bool result;
        if (bool.try_parse (str, out result) || str != "(null)") {
            val = result;
        }
        return val;
    }

    internal inline Value value_string_from_string (string str) {
        Value val = Value (typeof(string));
        if (str != "(null)") {
            val = str;
        }
        return val;
    }

    internal inline Value value_string_array_from_string (string str) {
        if (str == "NULL") {
            return Value (typeof(string[]));
        }

        string elements_str = str.replace ("[", "").replace ("]", "");
        string[] strings = elements_str.split (", ");

        return strings;
    }

    internal inline Value value_uchar_from_string (string str) {
        Value val = Value (typeof (uchar));
        uint result;
        if ((uint.try_parse (str, out result) && result >= 0 && result <= 255) || str != "(null)") {
            val = (uchar) result;
        }

        return val;
    }

    internal inline Value value_char_from_string (string str) {
        Value val = Value (typeof (char));
        if (str == "(null)") {
            return val;
        }

        int result;
        if (int.try_parse (str, out result) && result >= 0 && result <= 127) {
            val = (int8) result;
        }
        else {
            val = (int8) result;
        }

        return val;
    }

    internal inline Value value_unichar_from_string (string str) {
        Value val = Value (typeof (unichar));
        if (str == "(null)") {
            return val;
        }

        val = str.get_char (0);
        return val;
    }

    internal inline Value value_long_from_string (string str) {
        Value val = Value (typeof(long));
        long result;
        if (long.try_parse (str, out result) || str != "(null)") {
            val = result;
        }

        return val;
    }

    internal inline Value value_ulong_from_string (string str) {
        Value val = Value (typeof(ulong));
        ulong result;
        if (ulong.try_parse (str, out result) || str != "(null)") {
            val = result;
        }

        return val;
    }

    internal inline Value value_float_from_string (string str) {
        Value val = Value (typeof(float));
        float result;
        if (float.try_parse (str, out result) || str != "(null)") {
            val.set_float (result);
        }

        return val;
    }

    internal inline Value value_double_from_string (string str) {
        Value val = Value (typeof(double));
        double result;
        if (double.try_parse (str, out result) || str != "(null)") {
            val = result;
        }

        return val;
    }

    internal inline Value value_variant_from_string (string str) {
        Value val = Value (typeof(Variant));
        try {
            val = Variant.parse (null, str);
        }
        catch (Error e) {
            return val;
        }

        return val;
    }

    internal inline Value value_datetime_from_string (string str) {
        Value val = Value (typeof (DateTime));
        if (str == "(null)") {
            return val;
        }

        val = new DateTime.from_iso8601 (str, new TimeZone.local ());
        return val;
    }

    internal inline Value value_file_from_string (string str) {
        Value val = Value (typeof(File));
        if (str == "(null)") {
            return val;
        }

        val = File.new_for_path (str);
        return val;
    }

    internal inline Value value_uint_from_string (string str) {
        Value val = Value (typeof(uint));
        uint result;
        if (uint.try_parse (str, out result) || str != "(null)") {
            val = result;
        }

        return val;
    }

    internal inline Value value_enum_from_string (string str, Type type) {
        Value val = Value (type);
        EnumClass klass = (EnumClass) type.class_ref ();

        unowned EnumValue? eval = klass.get_value_by_name (str);
        if (eval != null) {
            val.set_enum (eval.value);
        }
        return val;
    }

    internal inline Value value_flags_from_string (string str, Type type) {
        Value val = Value (type);

        if (str == "0x0" || str == "(null)") {
            val.set_flags (0x0);
            return val;
        }

        FlagsClass klass = (FlagsClass) type.class_ref ();
        string[] values = str.split (" | ");

        uint flag_val = 0x0;
        foreach (string v in values) {
            unowned FlagsValue? fv = klass.get_value_by_name (v);
            if (fv == null) {
                continue;
            }
            flag_val += fv.value;
        }

        val.set_flags (flag_val);
        return val;
    }
}
