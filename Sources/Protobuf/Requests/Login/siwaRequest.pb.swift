// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: Requests/Login/siwaRequest.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

public struct SIWARequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var firstName: String {
    get {return _firstName ?? String()}
    set {_firstName = newValue}
  }
  /// Returns true if `firstName` has been explicitly set.
  public var hasFirstName: Bool {return self._firstName != nil}
  /// Clears the value of `firstName`. Subsequent reads from it will return its default value.
  public mutating func clearFirstName() {self._firstName = nil}

  public var lastName: String {
    get {return _lastName ?? String()}
    set {_lastName = newValue}
  }
  /// Returns true if `lastName` has been explicitly set.
  public var hasLastName: Bool {return self._lastName != nil}
  /// Clears the value of `lastName`. Subsequent reads from it will return its default value.
  public mutating func clearLastName() {self._lastName = nil}

  public var appleIdentityToken: String = String()

  public var email: String = String()

  public var deviceID: String = String()

  public var imageURL: String {
    get {return _imageURL ?? String()}
    set {_imageURL = newValue}
  }
  /// Returns true if `imageURL` has been explicitly set.
  public var hasImageURL: Bool {return self._imageURL != nil}
  /// Clears the value of `imageURL`. Subsequent reads from it will return its default value.
  public mutating func clearImageURL() {self._imageURL = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _firstName: String? = nil
  fileprivate var _lastName: String? = nil
  fileprivate var _imageURL: String? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension SIWARequest: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension SIWARequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "SIWARequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "firstName"),
    2: .same(proto: "lastName"),
    3: .same(proto: "appleIdentityToken"),
    4: .same(proto: "email"),
    5: .same(proto: "deviceID"),
    6: .same(proto: "imageURL"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self._firstName) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self._lastName) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.appleIdentityToken) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.email) }()
      case 5: try { try decoder.decodeSingularStringField(value: &self.deviceID) }()
      case 6: try { try decoder.decodeSingularStringField(value: &self._imageURL) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._firstName {
      try visitor.visitSingularStringField(value: v, fieldNumber: 1)
    } }()
    try { if let v = self._lastName {
      try visitor.visitSingularStringField(value: v, fieldNumber: 2)
    } }()
    if !self.appleIdentityToken.isEmpty {
      try visitor.visitSingularStringField(value: self.appleIdentityToken, fieldNumber: 3)
    }
    if !self.email.isEmpty {
      try visitor.visitSingularStringField(value: self.email, fieldNumber: 4)
    }
    if !self.deviceID.isEmpty {
      try visitor.visitSingularStringField(value: self.deviceID, fieldNumber: 5)
    }
    try { if let v = self._imageURL {
      try visitor.visitSingularStringField(value: v, fieldNumber: 6)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: SIWARequest, rhs: SIWARequest) -> Bool {
    if lhs._firstName != rhs._firstName {return false}
    if lhs._lastName != rhs._lastName {return false}
    if lhs.appleIdentityToken != rhs.appleIdentityToken {return false}
    if lhs.email != rhs.email {return false}
    if lhs.deviceID != rhs.deviceID {return false}
    if lhs._imageURL != rhs._imageURL {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}