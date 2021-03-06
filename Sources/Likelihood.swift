//
// Likelihood.swift
//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
// Licensed under the MIT License.
//

/// A bucketized representation of likelihood.
public enum Likelihood: APIRepresentationConvertible {

	/// Unknown likelihood.
	case Unknown

	/// The image very unlikely belongs to the vertical specified.
	case VeryUnlikely

	/// The image unlikely belongs to the vertical specified.
	case Unlikely

	/// The image possibly belongs to the vertical specified.
	case Possible

	/// The image likely belongs to the vertical specified.
	case Likely

	/// The image very likely belongs to the vertical specified.
	case VeryLikely

	// MARK: Errors

	/// Describes errors which can be thrown inside this type.
	public enum Error: ErrorType {

		/// Thrown if representation string is invalid.
		case InvalidStringValue

		/// Thrown if representation score is invalid.
		case InvalidScore
	}

	/// Calculated score of the likelihood.
	///
	/// - Warning: Calculating score from an `.Unknown` likelihood will cause a
 	///   runtime crash.
	public var score: Double {
		switch self {
			case .Unknown: fatalError("Cannot produce score value from unknown likelihood")
			case .VeryUnlikely: return 0.1
			case .Unlikely: return 0.3
			case .Possible: return 0.5
			case .Likely: return 0.7
			case .VeryLikely: return 0.9
		}
	}

	// MARK: Initializers

	/// Initializes the receiver with a string.
	///
	/// - Parameter string: The string representation of the receiver.
	///
	/// - Throws: `Error.InvalidString` if the string is invalid.
	public init(string: String) throws {
		switch string {
			case "UNKNOWN": self = .Unknown
			case "VERY_UNLIKELY": self = .VeryUnlikely
			case "UNLIKELY": self = .Unlikely
			case "POSSIBLE": self = .Possible
			case "LIKELY": self = .Likely
			case "VERY_LIKELY": self = .VeryLikely
			default: throw Error.InvalidStringValue
		}
	}

	/// Initializes the receiver with a score.
	///
	/// - Parameter score: The number representation of the receiver.
	///
	/// - Throws: `InvalidScore` if the score is not in range `0...1`.
	public init(score: Double) throws {
		switch score {
			case 0...0.2: self = .VeryUnlikely
			case 0.2...0.4: self = .Unlikely
			case 0.4...0.6: self = .Possible
			case 0.6...0.8: self = .Likely
			case 0.8...1: self = .VeryLikely
			default: throw Error.InvalidScore
		}
	}

	/// - SeeAlso: APIRepresentationConvertible.init(APIRepresentationValue:)
	public init(APIRepresentationValue value: APIRepresentationValue) throws {
		guard case .String(let string) = value else {
			throw APIRepresentationError.UnexpectedValueType
		}
		try self.init(string: string)
	}

}
