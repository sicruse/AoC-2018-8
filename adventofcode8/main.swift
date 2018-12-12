//
//  main.swift
//  adventofcode8
//
//  Created by Cruse, Si on 12/8/18.
//  Copyright © 2018 Cruse, Si. All rights reserved.
//

import Foundation

// Path to the problem input data
let path = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("input.txt")

func load(_ contentsOf: URL) -> [Int] {
    do {
        let data = try String(contentsOf: contentsOf)
        let strings = data.components(separatedBy: .newlines)
        return strings[0].split(separator: " ").map{Int($0)!}
    } catch {
        print(error)
        return []
    }
}

//    --- Day 8: Memory Maneuver ---
//    The sleigh is much easier to pull than you'd expect for something its weight. Unfortunately, neither you nor the Elves know which way the North Pole is from here.
//
//    You check your wrist device for anything that might help. It seems to have some kind of navigation system! Activating the navigation system produces more bad news: "Failed to start navigation system. Could not read software license file."
//
//    The navigation system's license file consists of a list of numbers (your puzzle input). The numbers define a data structure which, when processed, produces some kind of tree that can be used to calculate the license number.
//
//    The tree is made up of nodes; a single, outermost node forms the tree's root, and it contains all other nodes in the tree (or contains nodes that contain nodes, and so on).
//
//    Specifically, a node consists of:
//
//    A header, which is always exactly two numbers:
//    The quantity of child nodes.
//    The quantity of metadata entries.
//    Zero or more child nodes (as specified in the header).
//    One or more metadata entries (as specified in the header).
//    Each child node is itself a node that has its own header, child nodes, and metadata. For example:
//
//    2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2
//    A----------------------------------
//    B----------- C-----------
//    D-----
//    In this example, each node of the tree is also marked with an underline starting with a letter for easier identification. In it, there are four nodes:
//
//    A, which has 2 child nodes (B, C) and 3 metadata entries (1, 1, 2).
//    B, which has 0 child nodes and 3 metadata entries (10, 11, 12).
//    C, which has 1 child node (D) and 1 metadata entry (2).
//    D, which has 0 child nodes and 1 metadata entry (99).
//    The first check done on the license file is to simply add up all of the metadata entries. In this example, that sum is 1+1+2+10+11+12+2+99=138.
//
//    What is the sum of all metadata entries?

func decode(data: [Int]) -> (total: Int, score: Int , data: [Int]) {
    let children = data[0]
    let meta = data[1]
    var residual = Array(data.suffix(from: 2))
    var scores: [Int] = []
    var totals: Int = 0
    
    if children > 0 {
        for _ in 1...children {
            let (total, score, data) = decode(data: residual)
            residual = data
            totals += total
            scores.append(score)
        }
    }
    
    totals += residual.prefix(meta).reduce(0,+)
    
    if children == 0 {
        return (totals, residual.prefix(meta).reduce(0,+), Array(residual.suffix(from: meta)))
    } else {
        return (
            totals,
            residual.prefix(meta).reduce(0, {total, i in i > 0 && i <= scores.count ? (total + scores[i - 1]) : total }),
            Array(residual.suffix(from: meta))
        )
    }
}

// Utility function for running tests
func testit(scenario: (input: String, expected: Int), process: (String) -> Int) -> String {
    let result = process(scenario.input)
    return "\(result == scenario.expected ? "\u{1F49A}" : "\u{1F6D1}")\tresult \(result)\tinput: \(scenario.input)"
}

// Test Scenarios
let challenge_test_1 = ("2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2", 138)

func test1(input: String) -> Int {
    let data = input.split(separator: " ").map{Int($0)!}
    let calc = decode(data: data)
    return calc.total
}

print(testit(scenario: challenge_test_1, process: test1))

let calc = decode(data: load(path))
print("The FIRST CHALLENGE answer is \(calc.total)\n")

//        --- Part Two ---
//    The second check is slightly more complicated: you need to find the value of the root node (A in the example above).
//
//    The value of a node depends on whether it has child nodes.
//
//    If a node has no child nodes, its value is the sum of its metadata entries. So, the value of node B is 10+11+12=33, and the value of node D is 99.
//
//    However, if a node does have child nodes, the metadata entries become indexes which refer to those child nodes. A metadata entry of 1 refers to the first child node, 2 to the second, 3 to the third, and so on. The value of this node is the sum of the values of the child nodes referenced by the metadata entries. If a referenced child node does not exist, that reference is skipped. A child node can be referenced multiple time and counts each time it is referenced. A metadata entry of 0 does not refer to any child node.
//
//    For example, again using the above nodes:
//
//    Node C has one metadata entry, 2. Because node C has only one child node, 2 references a child node which does not exist, and so the value of node C is 0.
//    Node A has three metadata entries: 1, 1, and 2. The 1 references node A's first child node, B, and the 2 references node A's second child node, C. Because node B has a value of 33 and node C has a value of 0, the value of node A is 33+33+0=66.
//    So, in this example, the value of the root node is 66.
//
//    What is the value of the root node?
//

// Test Scenarios
let challenge_test_2 = ("2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2", 66)

func test2(input: String) -> Int {
    let data = input.split(separator: " ").map{Int($0)!}
    let calc = decode(data: data)
    return calc.score
}

print(testit(scenario: challenge_test_2, process: test2))

print("The SECOND CHALLENGE answer is \(calc.score)\n")

