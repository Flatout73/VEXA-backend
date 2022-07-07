// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: Models/content.proto
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

public struct Content {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var id: String {
    get {return _storage._id}
    set {_uniqueStorage()._id = newValue}
  }

  public var ambassador: Ambassador {
    get {return _storage._ambassador ?? Ambassador()}
    set {_uniqueStorage()._ambassador = newValue}
  }
  /// Returns true if `ambassador` has been explicitly set.
  public var hasAmbassador: Bool {return _storage._ambassador != nil}
  /// Clears the value of `ambassador`. Subsequent reads from it will return its default value.
  public mutating func clearAmbassador() {_uniqueStorage()._ambassador = nil}

  public var title: String {
    get {return _storage._title}
    set {_uniqueStorage()._title = newValue}
  }

  public var videoURL: String {
    get {return _storage._videoURL ?? String()}
    set {_uniqueStorage()._videoURL = newValue}
  }
  /// Returns true if `videoURL` has been explicitly set.
  public var hasVideoURL: Bool {return _storage._videoURL != nil}
  /// Clears the value of `videoURL`. Subsequent reads from it will return its default value.
  public mutating func clearVideoURL() {_uniqueStorage()._videoURL = nil}

  public var imageURL: String {
    get {return _storage._imageURL ?? String()}
    set {_uniqueStorage()._imageURL = newValue}
  }
  /// Returns true if `imageURL` has been explicitly set.
  public var hasImageURL: Bool {return _storage._imageURL != nil}
  /// Clears the value of `imageURL`. Subsequent reads from it will return its default value.
  public mutating func clearImageURL() {_uniqueStorage()._imageURL = nil}

  public var likesCount: Int32 {
    get {return _storage._likesCount}
    set {_uniqueStorage()._likesCount = newValue}
  }

  public var isLikedByMe: Bool {
    get {return _storage._isLikedByMe}
    set {_uniqueStorage()._isLikedByMe = newValue}
  }

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Content: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension Content: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "Content"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "ambassador"),
    3: .same(proto: "title"),
    4: .same(proto: "videoURL"),
    5: .same(proto: "imageURL"),
    6: .same(proto: "likesCount"),
    7: .same(proto: "isLikedByMe"),
  ]

  fileprivate class _StorageClass {
    var _id: String = String()
    var _ambassador: Ambassador? = nil
    var _title: String = String()
    var _videoURL: String? = nil
    var _imageURL: String? = nil
    var _likesCount: Int32 = 0
    var _isLikedByMe: Bool = false

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _id = source._id
      _ambassador = source._ambassador
      _title = source._title
      _videoURL = source._videoURL
      _imageURL = source._imageURL
      _likesCount = source._likesCount
      _isLikedByMe = source._isLikedByMe
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        // The use of inline closures is to circumvent an issue where the compiler
        // allocates stack space for every case branch when no optimizations are
        // enabled. https://github.com/apple/swift-protobuf/issues/1034
        switch fieldNumber {
        case 1: try { try decoder.decodeSingularStringField(value: &_storage._id) }()
        case 2: try { try decoder.decodeSingularMessageField(value: &_storage._ambassador) }()
        case 3: try { try decoder.decodeSingularStringField(value: &_storage._title) }()
        case 4: try { try decoder.decodeSingularStringField(value: &_storage._videoURL) }()
        case 5: try { try decoder.decodeSingularStringField(value: &_storage._imageURL) }()
        case 6: try { try decoder.decodeSingularInt32Field(value: &_storage._likesCount) }()
        case 7: try { try decoder.decodeSingularBoolField(value: &_storage._isLikedByMe) }()
        default: break
        }
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every if/case branch local when no optimizations
      // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
      // https://github.com/apple/swift-protobuf/issues/1182
      if !_storage._id.isEmpty {
        try visitor.visitSingularStringField(value: _storage._id, fieldNumber: 1)
      }
      try { if let v = _storage._ambassador {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      } }()
      if !_storage._title.isEmpty {
        try visitor.visitSingularStringField(value: _storage._title, fieldNumber: 3)
      }
      try { if let v = _storage._videoURL {
        try visitor.visitSingularStringField(value: v, fieldNumber: 4)
      } }()
      try { if let v = _storage._imageURL {
        try visitor.visitSingularStringField(value: v, fieldNumber: 5)
      } }()
      if _storage._likesCount != 0 {
        try visitor.visitSingularInt32Field(value: _storage._likesCount, fieldNumber: 6)
      }
      if _storage._isLikedByMe != false {
        try visitor.visitSingularBoolField(value: _storage._isLikedByMe, fieldNumber: 7)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Content, rhs: Content) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._id != rhs_storage._id {return false}
        if _storage._ambassador != rhs_storage._ambassador {return false}
        if _storage._title != rhs_storage._title {return false}
        if _storage._videoURL != rhs_storage._videoURL {return false}
        if _storage._imageURL != rhs_storage._imageURL {return false}
        if _storage._likesCount != rhs_storage._likesCount {return false}
        if _storage._isLikedByMe != rhs_storage._isLikedByMe {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
