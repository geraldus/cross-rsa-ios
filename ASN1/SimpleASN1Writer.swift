//
//  SimpleASN1Writer.swift
//  pgpt1
//
//  Created by Arthur Fayzrakhmanov on 09.10.2021.
//

import Foundation

public final class SimpleASN1Writer: SimpleASN1Writing {

    // Constants
    private let bitStringIdentifier: UInt8 = 0x03
    private let supportedFirstContentsByte: UInt8 = 0x00

    // Instance variable
    public private(set) var encoding: [UInt8] = []

    public init() {}

    public func write(from writer: SimpleASN1Writer) {
        encoding.insert(contentsOf: writer.encoding, at: 0)
    }

    public func write(_ bytes: [UInt8]) {
        encoding.insert(contentsOf: bytes, at: 0)
    }

    public func write(_ contents: [UInt8], identifiedBy identifier: UInt8) {
        encoding.insert(contentsOf: contents, at: 0)
        writeLengthAndIdentifier(with: identifier, onTopOf: contents)
    }

    public func wrap(with identifier: UInt8) {
        writeLengthAndIdentifier(with: identifier, onTopOf: encoding)
    }

    public func wrapBitString() {
        encoding.insert(supportedFirstContentsByte, at: 0)
        writeLengthAndIdentifier(with: bitStringIdentifier, onTopOf: encoding)
    }

    private func writeLengthAndIdentifier(with identifier: UInt8, onTopOf contents: [UInt8]) {
        encoding.insert(contentsOf: lengthField(of: contents), at: 0)
        encoding.insert(identifier, at: 0)
    }

    private func lengthField(of contentBytes: [UInt8]) -> [UInt8] {
        let length = contentBytes.count

        if length < 128 {
            return [UInt8(length)]
        }
        return longLengthField(of: contentBytes)
    }

    private func longLengthField(of contentBytes: [UInt8]) -> [UInt8] {
        var length = contentBytes.count

        // Number of bytes needed to encode the length
        let lengthFieldCount = Int((log2(Double(length)) / 8) + 1)
        var lengthField: [UInt8] = []

        for _ in 0..<lengthFieldCount {

            // Take the last 8 bits of length
            let lengthByte = UInt8(length & 0xff)

            // Insert them at the beginning of the array
            lengthField.insert(lengthByte, at: 0)

            // Delete the last 8 bits of length
            length = length >> 8
        }
        let firstByte = UInt8(128 + lengthFieldCount)

        // Insert first byte at the beginning of the array
        lengthField.insert(firstByte, at: 0)

        return lengthField
    }
}

/// The `SimpleASN1Writing` protocol describes how a DER encoding can be created or updated by
/// inserting bytes on top of bytes that have been written before.
///
/// Simple in this context means:
/// - No conversion between Swift data types and bytes (so, only bytes in)
/// - No high tag numbers (that is, tag numbers are encoded by a single byte)
/// - No support for encodings that have an indefinite length
///
/// Note that this protocol is designed in a way that multiple instances of an implementation should
/// be created if the encoding has a tree-like structure that forks into multiple branches.
public protocol SimpleASN1Writing: AnyObject {

    /// All encoded bytes added to this writer.
    var encoding: [UInt8] { get }

    /// Convenience method that adds the encoding of another instance to the current instance. All
    /// bytes of the `SimpleASN1Writer` will be written on top of bytes written below (as a sibling).
    ///
    /// - Parameter writer: Another instance of a class implementing this protocol.
    func write(from writer: SimpleASN1Writer)

    /// Writes bytes on top of all bytes written below (as a sibling).
    ///
    /// - Parameter bytes: The bytes that will be written on top of bytes below.
    func write(_ bytes: [UInt8])

    /// Writes contents, length and identifier bytes, in that particular order, on top of all bytes
    /// written below. The number represented by the length bytes applies to the number of contents
    /// bytes of the added component.
    ///
    /// If the identifier denotes a bit string, the first byte of the contents must give the number of
    /// bits by which the length of the bit string is less than the next multiple of eight (this is
    /// called the “number of unused bits”). Both the padding after the last bit and the inclusion of
    /// the first contents byte – which gives the length of this padding – will be considered the
    /// responsibility of the client.
    ///
    /// - Parameters:
    ///   - contents: The contents bytes of the component.
    ///   - identifier: The ASN.1 identifier of the component.
    func write(_ contents: [UInt8], identifiedBy identifier: UInt8)

    /// Writes length and identifier bytes, in that particular order, to wrap all bytes written below.
    ///
    /// - Parameter identifier: The ASN.1 identifier byte that will be written on top of the length
    ///     bytes and all bytes below.
    func wrap(with identifier: UInt8)

    /// Writes length and identifier bytes of a bit string, in that particular order, to wrap all
    /// bytes written below. The bit string is assumed to have no unused bits (that is, the fist
    /// contents byte has value 0x00).
    func wrapBitString()
}
