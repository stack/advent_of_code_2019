//
//  Data.swift
//  Day 22
//
//  Created by Stephen H. Gerstacker on 2019-12-22.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import BigInt
import Utilities

struct Data {

    static let sample1TotalCards: BigInt = BigInt(10)
    static let sample1CardsToWatch: [BigInt] = Array(0 ..< 10)
    static let sample1Instructions = """
        deal into new stack
        """

    static let sample2TotalCards: BigInt = BigInt(10)
    static let sample2CardsToWatch: [BigInt] = Array(0 ..< 10)
    static let sample2Instructions = """
        cut 3
        """

    static let sample3TotalCards: BigInt = BigInt(10)
    static let sample3CardsToWatch: [BigInt] = Array(0 ..< 10)
    static let sample3Instructions = """
        cut -4
        """

    static let sample4TotalCards: BigInt = BigInt(10)
    static let sample4CardsToWatch: [BigInt] = Array(0 ..< 10)
    static let sample4Instructions = """
        deal with increment 3
        """

    static let sample5TotalCards: BigInt = BigInt(10)
    static let sample5CardsToWatch: [BigInt] = Array(0 ..< 10)
    static let sample5Instructions = """
        deal with increment 7
        deal into new stack
        deal into new stack
        """

    static let sample6TotalCards: BigInt = BigInt(10)
    static let sample6CardsToWatch: [BigInt] = Array(0 ..< 10)
    static let sample6Instructions = """
        cut 6
        deal with increment 7
        deal into new stack
        """

    static let sample7TotalCards: BigInt = BigInt(10)
    static let sample7CardsToWatch: [BigInt] = Array(0 ..< 10)
    static let sample7Instructions = """
        deal with increment 7
        deal with increment 9
        cut -2
        """

    static let sample8TotalCards: BigInt = BigInt(10)
    static let sample8CardsToWatch: [BigInt] = Array(0 ..< 10)
    static let sample8Instructions = """
        deal into new stack
        cut -2
        deal with increment 7
        cut 8
        cut -4
        deal with increment 7
        cut 3
        deal with increment 9
        deal with increment 3
        cut -1
        """

    static let inputTotalCards: BigInt = BigInt(10)
    static let inputCardsToWatch: [BigInt] = [2019]
    static let inputInstructions = """
        cut 4753
        deal with increment 64
        cut 9347
        deal with increment 64
        cut 4913
        deal with increment 33
        cut 6371
        deal with increment 53
        cut -7660
        deal with increment 65
        cut 7992
        deal with increment 29
        cut 7979
        deal with increment 28
        cut -6056
        deal with increment 5
        cut -3096
        deal with increment 13
        cut -4315
        deal with increment 52
        cut 2048
        deal into new stack
        cut 9126
        deal with increment 67
        deal into new stack
        cut -4398
        deal with increment 29
        cut 5230
        deal with increment 30
        cut 1150
        deal with increment 41
        cut 668
        deal into new stack
        cut -7265
        deal with increment 69
        deal into new stack
        deal with increment 38
        cut -8498
        deal with increment 68
        deal into new stack
        deal with increment 30
        cut -1108
        deal with increment 7
        cut 5875
        deal with increment 13
        cut -8614
        deal with increment 44
        cut -9866
        deal with increment 2
        cut 2582
        deal with increment 43
        cut 6628
        deal with increment 59
        deal into new stack
        cut 7514
        deal into new stack
        cut -115
        deal with increment 14
        cut 2844
        deal with increment 4
        cut 6564
        deal with increment 23
        cut -8148
        deal with increment 12
        cut -81
        deal with increment 2
        cut 9928
        deal with increment 8
        cut 3174
        deal with increment 28
        deal into new stack
        cut 6259
        deal with increment 3
        cut 1863
        deal with increment 34
        deal into new stack
        cut 4751
        deal into new stack
        cut -7394
        deal with increment 59
        deal into new stack
        deal with increment 28
        deal into new stack
        deal with increment 59
        cut -848
        deal with increment 19
        deal into new stack
        cut -575
        deal with increment 60
        deal into new stack
        deal with increment 74
        cut 514
        deal into new stack
        cut 8660
        deal with increment 3
        cut 5325
        deal with increment 41
        deal into new stack
        deal with increment 10
        deal into new stack
        """
}
