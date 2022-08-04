/* structs.vala
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
    private struct Property {
        public string name;
        public Type type;
    }

    private abstract class ParserType {
        public Type type { get; protected set; }
    }

    private class SerializableType : ParserType {
        public TypeSerializationFunc func { get; private set; }
        public SerializableType (Type t, owned TypeSerializationFunc f) {
            type = t;
            func = (owned) f;
        }
    }

    private class DeserializableType : ParserType {
        public TypeDeserializationFunc func { get; private set; }
        public DeserializableType (Type t, owned TypeDeserializationFunc f) {
            type = t;
            func = (owned) f;
        }
    }
}
