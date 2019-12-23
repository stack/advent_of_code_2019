//
//  Data.swift
//  Day 23
//
//  Created by Stephen H. Gerstacker on 2019-12-23.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Utilities

struct Data {

    static let input = [3, 62, 1001, 62, 11, 10, 109, 2275, 105, 1, 0, 1919, 2036, 1758, 1723, 600, 2131, 1220, 637, 1826, 1498, 767, 1002, 1331, 1960, 1593, 2201, 901, 1292, 1886, 1562, 1189, 1426, 571, 1651, 734, 1364, 1455, 1257, 1789, 699, 1995, 868, 1074, 2100, 1150, 2232, 967, 1103, 1688, 2162, 2067, 1622, 798, 1395, 668, 932, 1035, 1855, 1531, 831, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 64, 1008, 64, -1, 62, 1006, 62, 88, 1006, 61, 170, 1105, 1, 73, 3, 65, 21002, 64, 1, 1, 21002, 66, 1, 2, 21102, 1, 105, 0, 1105, 1, 436, 1201, 1, -1, 64, 1007, 64, 0, 62, 1005, 62, 73, 7, 64, 67, 62, 1006, 62, 73, 1002, 64, 2, 133, 1, 133, 68, 133, 101, 0, 0, 62, 1001, 133, 1, 140, 8, 0, 65, 63, 2, 63, 62, 62, 1005, 62, 73, 1002, 64, 2, 161, 1, 161, 68, 161, 1102, 1, 1, 0, 1001, 161, 1, 169, 101, 0, 65, 0, 1101, 1, 0, 61, 1101, 0, 0, 63, 7, 63, 67, 62, 1006, 62, 203, 1002, 63, 2, 194, 1, 68, 194, 194, 1006, 0, 73, 1001, 63, 1, 63, 1105, 1, 178, 21101, 210, 0, 0, 105, 1, 69, 2101, 0, 1, 70, 1102, 1, 0, 63, 7, 63, 71, 62, 1006, 62, 250, 1002, 63, 2, 234, 1, 72, 234, 234, 4, 0, 101, 1, 234, 240, 4, 0, 4, 70, 1001, 63, 1, 63, 1105, 1, 218, 1105, 1, 73, 109, 4, 21102, 1, 0, -3, 21101, 0, 0, -2, 20207, -2, 67, -1, 1206, -1, 293, 1202, -2, 2, 283, 101, 1, 283, 283, 1, 68, 283, 283, 22001, 0, -3, -3, 21201, -2, 1, -2, 1105, 1, 263, 21202, -3, 1, -3, 109, -4, 2106, 0, 0, 109, 4, 21101, 0, 1, -3, 21101, 0, 0, -2, 20207, -2, 67, -1, 1206, -1, 342, 1202, -2, 2, 332, 101, 1, 332, 332, 1, 68, 332, 332, 22002, 0, -3, -3, 21201, -2, 1, -2, 1106, 0, 312, 22101, 0, -3, -3, 109, -4, 2106, 0, 0, 109, 1, 101, 1, 68, 359, 20101, 0, 0, 1, 101, 3, 68, 366, 21001, 0, 0, 2, 21102, 1, 376, 0, 1106, 0, 436, 21202, 1, 1, 0, 109, -1, 2106, 0, 0, 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, 16777216, 33554432, 67108864, 134217728, 268435456, 536870912, 1073741824, 2147483648, 4294967296, 8589934592, 17179869184, 34359738368, 68719476736, 137438953472, 274877906944, 549755813888, 1099511627776, 2199023255552, 4398046511104, 8796093022208, 17592186044416, 35184372088832, 70368744177664, 140737488355328, 281474976710656, 562949953421312, 1125899906842624, 109, 8, 21202, -6, 10, -5, 22207, -7, -5, -5, 1205, -5, 521, 21102, 0, 1, -4, 21102, 0, 1, -3, 21102, 51, 1, -2, 21201, -2, -1, -2, 1201, -2, 385, 471, 20102, 1, 0, -1, 21202, -3, 2, -3, 22207, -7, -1, -5, 1205, -5, 496, 21201, -3, 1, -3, 22102, -1, -1, -5, 22201, -7, -5, -7, 22207, -3, -6, -5, 1205, -5, 515, 22102, -1, -6, -5, 22201, -3, -5, -3, 22201, -1, -4, -4, 1205, -2, 461, 1106, 0, 547, 21101, -1, 0, -4, 21202, -6, -1, -6, 21207, -7, 0, -5, 1205, -5, 547, 22201, -7, -6, -7, 21201, -4, 1, -4, 1106, 0, 529, 22102, 1, -4, -7, 109, -8, 2105, 1, 0, 109, 1, 101, 1, 68, 563, 21002, 0, 1, 0, 109, -1, 2105, 1, 0, 1101, 0, 42979, 66, 1101, 1, 0, 67, 1102, 598, 1, 68, 1102, 1, 556, 69, 1101, 0, 0, 71, 1102, 600, 1, 72, 1105, 1, 73, 1, 1468, 1101, 0, 34273, 66, 1102, 4, 1, 67, 1101, 0, 627, 68, 1102, 1, 302, 69, 1101, 1, 0, 71, 1101, 0, 635, 72, 1105, 1, 73, 0, 0, 0, 0, 0, 0, 0, 0, 17, 199497, 1102, 61981, 1, 66, 1101, 0, 1, 67, 1102, 664, 1, 68, 1102, 556, 1, 69, 1101, 1, 0, 71, 1102, 666, 1, 72, 1105, 1, 73, 1, 67, 34, 132292, 1102, 1, 557, 66, 1101, 0, 1, 67, 1102, 1, 695, 68, 1102, 556, 1, 69, 1101, 1, 0, 71, 1102, 1, 697, 72, 1105, 1, 73, 1, 1079, 49, 359564, 1101, 54499, 0, 66, 1101, 3, 0, 67, 1101, 726, 0, 68, 1102, 302, 1, 69, 1101, 0, 1, 71, 1102, 732, 1, 72, 1106, 0, 73, 0, 0, 0, 0, 0, 0, 23, 283916, 1102, 17599, 1, 66, 1101, 2, 0, 67, 1101, 761, 0, 68, 1101, 0, 302, 69, 1101, 0, 1, 71, 1102, 765, 1, 72, 1106, 0, 73, 0, 0, 0, 0, 42, 101173, 1102, 1, 69899, 66, 1101, 1, 0, 67, 1102, 1, 794, 68, 1101, 556, 0, 69, 1101, 0, 1, 71, 1101, 0, 796, 72, 1105, 1, 73, 1, 65323, 36, 3557, 1101, 101173, 0, 66, 1102, 1, 2, 67, 1102, 825, 1, 68, 1101, 302, 0, 69, 1101, 0, 1, 71, 1102, 829, 1, 72, 1105, 1, 73, 0, 0, 0, 0, 40, 46538, 1101, 89891, 0, 66, 1101, 0, 4, 67, 1102, 1, 858, 68, 1102, 302, 1, 69, 1102, 1, 1, 71, 1101, 0, 866, 72, 1106, 0, 73, 0, 0, 0, 0, 0, 0, 0, 0, 17, 66499, 1101, 27967, 0, 66, 1102, 2, 1, 67, 1101, 895, 0, 68, 1101, 351, 0, 69, 1102, 1, 1, 71, 1102, 1, 899, 72, 1105, 1, 73, 0, 0, 0, 0, 255, 99289, 1102, 68071, 1, 66, 1101, 1, 0, 67, 1101, 928, 0, 68, 1102, 1, 556, 69, 1102, 1, 1, 71, 1101, 0, 930, 72, 1106, 0, 73, 1, 683, 49, 89891, 1102, 1, 54881, 66, 1101, 0, 3, 67, 1102, 1, 959, 68, 1102, 302, 1, 69, 1101, 1, 0, 71, 1102, 1, 965, 72, 1105, 1, 73, 0, 0, 0, 0, 0, 0, 3, 192586, 1102, 1, 3557, 66, 1102, 3, 1, 67, 1101, 0, 994, 68, 1101, 302, 0, 69, 1102, 1, 1, 71, 1101, 0, 1000, 72, 1106, 0, 73, 0, 0, 0, 0, 0, 0, 17, 265996, 1101, 29669, 0, 66, 1102, 2, 1, 67, 1102, 1, 1029, 68, 1102, 1, 302, 69, 1101, 0, 1, 71, 1102, 1, 1033, 72, 1106, 0, 73, 0, 0, 0, 0, 23, 70979, 1102, 22369, 1, 66, 1102, 5, 1, 67, 1102, 1, 1062, 68, 1102, 1, 302, 69, 1102, 1, 1, 71, 1102, 1, 1072, 72, 1106, 0, 73, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 29, 163497, 1102, 1, 40361, 66, 1101, 0, 1, 67, 1101, 0, 1101, 68, 1102, 1, 556, 69, 1101, 0, 0, 71, 1101, 1103, 0, 72, 1105, 1, 73, 1, 1327, 1101, 3167, 0, 66, 1102, 1, 1, 67, 1101, 0, 1130, 68, 1102, 1, 556, 69, 1101, 9, 0, 71, 1102, 1, 1132, 72, 1105, 1, 73, 1, 1, 4, 102819, 27, 272091, 12, 56087, 49, 269673, 18, 14506, 24, 17599, 42, 202346, 40, 23269, 39, 82891, 1102, 1, 33073, 66, 1102, 5, 1, 67, 1102, 1, 1177, 68, 1101, 0, 302, 69, 1102, 1, 1, 71, 1101, 0, 1187, 72, 1105, 1, 73, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 23, 141958, 1102, 1, 48679, 66, 1101, 0, 1, 67, 1102, 1, 1216, 68, 1101, 0, 556, 69, 1101, 0, 1, 71, 1102, 1, 1218, 72, 1106, 0, 73, 1, -67, 4, 68546, 1102, 1, 34667, 66, 1101, 1, 0, 67, 1101, 1247, 0, 68, 1102, 556, 1, 69, 1101, 0, 4, 71, 1102, 1, 1249, 72, 1105, 1, 73, 1, 5, 49, 179782, 28, 94559, 28, 283677, 30, 209877, 1102, 90697, 1, 66, 1102, 1, 3, 67, 1101, 1284, 0, 68, 1101, 302, 0, 69, 1101, 1, 0, 71, 1101, 1290, 0, 72, 1106, 0, 73, 0, 0, 0, 0, 0, 0, 17, 132998, 1101, 0, 66499, 66, 1102, 1, 5, 67, 1102, 1319, 1, 68, 1101, 0, 253, 69, 1101, 0, 1, 71, 1102, 1, 1329, 72, 1105, 1, 73, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 45, 109762, 1101, 56087, 0, 66, 1101, 2, 0, 67, 1102, 1, 1358, 68, 1101, 302, 0, 69, 1101, 1, 0, 71, 1102, 1362, 1, 72, 1106, 0, 73, 0, 0, 0, 0, 17, 332495, 1102, 31583, 1, 66, 1101, 1, 0, 67, 1101, 0, 1391, 68, 1102, 556, 1, 69, 1101, 1, 0, 71, 1101, 0, 1393, 72, 1105, 1, 73, 1, 107, 39, 165782, 1102, 73681, 1, 66, 1101, 1, 0, 67, 1102, 1, 1422, 68, 1101, 556, 0, 69, 1102, 1, 1, 71, 1101, 1424, 0, 72, 1106, 0, 73, 1, -32443, 12, 112174, 1102, 34351, 1, 66, 1102, 1, 1, 67, 1102, 1, 1453, 68, 1102, 556, 1, 69, 1101, 0, 0, 71, 1102, 1, 1455, 72, 1105, 1, 73, 1, 1032, 1102, 1, 50551, 66, 1102, 1, 1, 67, 1101, 1482, 0, 68, 1102, 1, 556, 69, 1102, 7, 1, 71, 1102, 1484, 1, 72, 1105, 1, 73, 1, 3, 36, 7114, 36, 10671, 45, 54881, 3, 288879, 34, 66146, 46, 44738, 46, 67107, 1101, 0, 100151, 66, 1102, 1, 1, 67, 1102, 1525, 1, 68, 1102, 556, 1, 69, 1102, 1, 2, 71, 1101, 1527, 0, 72, 1106, 0, 73, 1, 10, 28, 189118, 30, 69959, 1101, 53353, 0, 66, 1101, 1, 0, 67, 1102, 1558, 1, 68, 1102, 1, 556, 69, 1101, 0, 1, 71, 1101, 1560, 0, 72, 1105, 1, 73, 1, 160, 30, 279836, 1102, 1, 92269, 66, 1102, 1, 1, 67, 1101, 1589, 0, 68, 1101, 0, 556, 69, 1101, 0, 1, 71, 1101, 1591, 0, 72, 1106, 0, 73, 1, 125, 28, 378236, 1101, 0, 72859, 66, 1102, 1, 1, 67, 1101, 1620, 0, 68, 1102, 1, 556, 69, 1101, 0, 0, 71, 1102, 1622, 1, 72, 1106, 0, 73, 1, 1757, 1102, 1, 84673, 66, 1101, 0, 1, 67, 1102, 1, 1649, 68, 1101, 0, 556, 69, 1102, 1, 0, 71, 1101, 0, 1651, 72, 1105, 1, 73, 1, 1991, 1101, 0, 70979, 66, 1102, 1, 4, 67, 1102, 1678, 1, 68, 1102, 1, 253, 69, 1101, 0, 1, 71, 1102, 1, 1686, 72, 1106, 0, 73, 0, 0, 0, 0, 0, 0, 0, 0, 31, 27967, 1102, 1, 12473, 66, 1102, 3, 1, 67, 1102, 1, 1715, 68, 1102, 1, 302, 69, 1102, 1, 1, 71, 1101, 1721, 0, 72, 1105, 1, 73, 0, 0, 0, 0, 0, 0, 23, 212937, 1102, 96293, 1, 66, 1101, 0, 3, 67, 1102, 1, 1750, 68, 1102, 1, 302, 69, 1102, 1, 1, 71, 1102, 1756, 1, 72, 1105, 1, 73, 0, 0, 0, 0, 0, 0, 34, 99219, 1101, 0, 104369, 66, 1101, 1, 0, 67, 1101, 0, 1785, 68, 1102, 1, 556, 69, 1101, 1, 0, 71, 1102, 1787, 1, 72, 1106, 0, 73, 1, 214, 39, 414455, 1102, 1, 94559, 66, 1101, 4, 0, 67, 1101, 1816, 0, 68, 1101, 0, 302, 69, 1101, 1, 0, 71, 1102, 1824, 1, 72, 1106, 0, 73, 0, 0, 0, 0, 0, 0, 0, 0, 30, 349795, 1102, 1, 41077, 66, 1102, 1, 1, 67, 1102, 1853, 1, 68, 1101, 556, 0, 69, 1102, 0, 1, 71, 1102, 1855, 1, 72, 1105, 1, 73, 1, 1037, 1102, 1, 569, 66, 1102, 1, 1, 67, 1102, 1882, 1, 68, 1101, 0, 556, 69, 1102, 1, 1, 71, 1102, 1, 1884, 72, 1105, 1, 73, 1, 13183, 27, 90697, 1101, 7253, 0, 66, 1101, 0, 2, 67, 1102, 1913, 1, 68, 1101, 0, 302, 69, 1101, 1, 0, 71, 1101, 0, 1917, 72, 1105, 1, 73, 0, 0, 0, 0, 24, 35198, 1101, 99289, 0, 66, 1102, 1, 1, 67, 1101, 1946, 0, 68, 1101, 556, 0, 69, 1102, 6, 1, 71, 1101, 0, 1948, 72, 1106, 0, 73, 1, 24807, 11, 29669, 29, 54499, 29, 108998, 38, 12473, 38, 24946, 38, 37419, 1102, 8693, 1, 66, 1102, 1, 1, 67, 1101, 0, 1987, 68, 1101, 0, 556, 69, 1101, 0, 3, 71, 1102, 1989, 1, 72, 1106, 0, 73, 1, 13, 4, 137092, 34, 33073, 46, 111845, 1102, 1, 69959, 66, 1102, 6, 1, 67, 1102, 2022, 1, 68, 1101, 302, 0, 69, 1101, 0, 1, 71, 1101, 2034, 0, 72, 1105, 1, 73, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 31, 55934, 1101, 0, 5683, 66, 1101, 0, 1, 67, 1101, 0, 2063, 68, 1101, 556, 0, 69, 1101, 0, 1, 71, 1101, 2065, 0, 72, 1105, 1, 73, 1, 31387, 18, 7253, 1102, 23269, 1, 66, 1101, 0, 2, 67, 1102, 1, 2094, 68, 1101, 0, 302, 69, 1102, 1, 1, 71, 1102, 2098, 1, 72, 1106, 0, 73, 0, 0, 0, 0, 39, 331564, 1102, 1, 50263, 66, 1101, 0, 1, 67, 1102, 2127, 1, 68, 1102, 556, 1, 69, 1101, 1, 0, 71, 1101, 0, 2129, 72, 1105, 1, 73, 1, 61, 4, 34273, 1102, 1171, 1, 66, 1102, 1, 1, 67, 1102, 1, 2158, 68, 1101, 0, 556, 69, 1101, 0, 1, 71, 1102, 2160, 1, 72, 1106, 0, 73, 1, 25, 27, 181394, 1101, 0, 82891, 66, 1101, 5, 0, 67, 1102, 1, 2189, 68, 1102, 1, 302, 69, 1101, 0, 1, 71, 1101, 2199, 0, 72, 1106, 0, 73, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 59338, 1101, 92459, 0, 66, 1101, 1, 0, 67, 1101, 0, 2228, 68, 1101, 0, 556, 69, 1102, 1, 1, 71, 1102, 1, 2230, 72, 1106, 0, 73, 1, -201, 46, 89476, 1102, 1, 28387, 66, 1101, 0, 1, 67, 1101, 0, 2259, 68, 1101, 556, 0, 69, 1101, 0, 7, 71, 1102, 1, 2261, 72, 1106, 0, 73, 1, 2, 45, 164643, 3, 96293, 34, 165365, 39, 248673, 46, 22369, 30, 139918, 30, 419754]
}
