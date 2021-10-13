//
//  Utils.swift
//  pgpt1
//
//  Created by Arthur Fayzrakhmanov on 30.09.2021.
//

import Foundation

func getPublicKeyString(key: SecKey) -> String? {
    let publicKeyCopy = SecKeyCopyPublicKey(key)!
    var result: String? = nil
    do {
        var error: Unmanaged<CFError>?
        guard let secKeyExport = SecKeyCopyExternalRepresentation(publicKeyCopy, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        let pubData = secKeyExport as Data?
        result = RSAPublicKeyExporter().toSubjectPublicKeyInfo(pubData!).base64EncodedString()
    } catch {
        print("Error getting public key copy")
    }
    return result
}

func userPrivateKeyQuery(atag alias: String, returnRef: Bool = true) -> [String: Any] {
    let tag = alias.data(using: .utf8)!
    return [kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecReturnRef as String: returnRef]
}


//
//  From RSAPublicKeyExporter.swift
//  rsa-public-key-importer-exporter
//
//  Created by nextincrement on 27/07/2019.
//  Copyright © 2019 nextincrement
//

public struct RSAPublicKeyExporter: RSAPublicKeyExporting {

    // ASN.1 identifier byte
    public let sequenceIdentifier: UInt8 = 0x30

    // ASN.1 AlgorithmIdentfier for RSA encryption: OID 1 2 840 113549 1 1 1 and NULL
    private let algorithmIdentifierForRSAEncryption: [UInt8] = [0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86,
                                                                0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00]

    public init() {}

    public func toSubjectPublicKeyInfo(_ rsaPublicKey: Data) -> Data {
        let writer = SimpleASN1Writer()

        // Insert the ‘unwrapped’ DER encoding of the RSA public key
        writer.write([UInt8](rsaPublicKey))

        // Insert ASN.1 BIT STRING length and identifier bytes on top of it (as a wrapper)
        writer.wrapBitString()

        // Insert ASN.1 AlgorithmIdentifier bytes on top of it (as a sibling)
        writer.write(algorithmIdentifierForRSAEncryption)

        // Insert ASN.1 SEQUENCE length and identifier bytes on top it (as a wrapper)
        writer.wrap(with: sequenceIdentifier)

        return Data(writer.encoding)
    }
}

/// The `RSAPublicKeyExporting` protocol defines how to convert the DER encoding of an RSA
/// public key to a format typically used by tools and programming languages outside the iOS
/// ecosystem (e.g. OpenSSL, Java, PHP and Perl). The DER encoding of an RSA public key created
/// by iOS is represented with the ASN.1 RSAPublicKey type as defined by PKCS #1. However, many
/// systems outside the Apple ecosystem expect the DER encoding of a key to be represented with
/// the ASN.1 SubjectPublicKeyInfo type as defined by X.509. The types are related in a way that
/// if the algorithm field of the SubjectPublicKeyInfo type contains the rsaEncryption object
/// identifier as defined by PKCS #1, the subjectPublicKey field shall contain the DER encoding
/// of an RSA key that is represented with the RSAPublicKey type.
///
/// ### Security Considerations
/// If exchanging bare public keys over a network (that is, without using a verified certificate),
/// consider setting up a TLS secured connection before sending any (additional) keys. And if
/// exchanging bare public keys more than once, e.g. after enrolling the app, consider using an
/// additional encryption layer on top of TLS. In any case, the encryption algorithm used in the
/// encryption process must be as ‘strong’ as the keys that are sent.
public protocol RSAPublicKeyExporting {

    /// This method converts a BER encoding of an RSA public key that is represented with the
    /// ASN.1 RSAPublicKey type, to a BER encoding that is represented with the ASN.1
    /// SubjectPublicKeyInfo type.
    ///
    /// Note that the parameter is assumed to be DER encoded, and if this assumption is correct, the
    /// result will be DER encoded as well. However, it will not be verified that the provided key
    /// is in fact DER encoded.
    ///
    /// - Parameter rsaPublicKey: A data object containing the DER (or BER) encoding of an RSA
    ///     public key, which is represented with the ASN.1 RSAPublicKey type.
    /// - Returns: A data object containing the DER (or BER) encoding of an RSA public key,
    ///     which is represented with the ASN.1 SubjectPublicKeyInfo type.
    func toSubjectPublicKeyInfo(_ rsaPublicKey: Data) -> Data
}
