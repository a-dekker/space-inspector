/*
    Space Inspector - a filesystem structure visualization for SailfishOS

    SPDX-FileCopyrightText: Copyright (C) 2014 - 2018 Jens Klingen
    SPDX-FileCopyrightText: 2024 Mirian Margiani

    SPDX-License-Identifier: GPL-3.0-or-later

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

.pragma library

var _colorCache = {}
function colorForFile(nodeName) {
    var ext = getFileExtension(nodeName)

    if (!_colorCache.hasOwnProperty(ext)) {
        _colorCache[ext] = Qt.hsla(getNormalizedHash(ext),
                                   1, 0.5, 0.75)
    }

    return _colorCache[ext]
}

/**
 * Extracts file extension from path.
 * The portion after the last "." in the filename is considered to be an extension,
 * (ecxept when the last dot is the first character of the filename.
 * Returns null if the file does not have an extension.
 */
function getFileExtension(nodeName) {
    var dotIdx = nodeName.lastIndexOf(".");
    return dotIdx > 0 ? nodeName.substring(dotIdx + 1) : null;
}

/**
 * Hashes a string to a number where 0 <= ret < 1
 */
var _hashCache = {}
function getNormalizedHash(str) {
    if (!_hashCache.hasOwnProperty(str)) {
        var ret = 0;
        if (str) {
            str = str.toLowerCase();

            for (var i = 0; i < str.length; i++) {
                var c = str.charCodeAt(i);
                if (c >= 97 && c < 123) c -= 97;
                //a-z will be 0-25
                else if (c >= 48 && c < 58) c -= 18; // 0-9 will be 26-35
                //console.log("should be between 0 and 35: "+c)
                c = (c / 35) * 0.9; // normalize each to be between 0 and 0.9
                //console.log("should be between 0 and 0.9: "+c)
                c /= Math.pow(10, i); // 1st letter has more influence than 2nd
                //console.log(c);
                ret += c;
            }
        }

        //console.log(str+"--->"+ret)
        _hashCache[str] = ret;
    }

    return _hashCache[str];
}
