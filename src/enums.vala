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
        ONLY_REQUIRED_QUOTES
    }
}
