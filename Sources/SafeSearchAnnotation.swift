//
// SafeSearchAnnotation.swift
//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
// Licensed under the MIT License.
//

/// Describes the result of safe search detection.
public struct SafeSearchAnnotation: APIRepresentationConvertible {

	/// Likelihood of image containing adult contents.
	let adultContentLikelihood: Likelihood

	/// Likelihood that an obvious modification was made to the image's
	/// canonical version to make it appear funny or offensive.
	let spoofContentLikelihood: Likelihood

	/// Likelihood of image containing medical content.
	let medicalContentLikelihood: Likelihood

	/// Likelihood of image containing violent content.
	let violentContentLikelihood: Likelihood

	// swiftlint:disable force_try

	/// Likelihood of unsafe content, calculated using adult, spoof, medical and violent
	/// contents likelihoods.
	///
	/// - Throws: Rethrows any errors thrown while creating combined
	/// unsafe content `Likelihood` using calculated score.
	///
	/// - Returns: Likelihood of unsafe content.
	public var unsafeContentLikelihood: Likelihood {
		guard
			adultContentLikelihood != .Unknown &&
			violentContentLikelihood != .Unknown &&
			medicalContentLikelihood != .Unknown &&
			spoofContentLikelihood != .Unknown
		else {
			return .Unknown
		}
		// Since other likelihoods are not unknown, we will never get score out of range here.
		return try! Likelihood(
			score: (
				max(adultContentLikelihood.score, violentContentLikelihood.score) * 8 +
				medicalContentLikelihood.score  +
				spoofContentLikelihood.score
			) / 10
		)
	}

	// swiftlint:enable force_try

	// MARK: Initializers

	/// Initializes the receiver with raw values.
	///
	/// - Parameters:
	///     - adultContentLikelihood: Likelihood of adult content.
	///     - spoofContentLikelihood: Likelihood of spoof content.
	///     - medicalContentLikelihood: Likelihood of medical content.
	///     - violentContentLikelihood: Likelihood of violent content.
	public init(
		adultContentLikelihood: Likelihood,
		spoofContentLikelihood: Likelihood,
		medicalContentLikelihood: Likelihood,
		violentContentLikelihood: Likelihood
	) {
		self.adultContentLikelihood = adultContentLikelihood
		self.spoofContentLikelihood = spoofContentLikelihood
		self.medicalContentLikelihood = medicalContentLikelihood
		self.violentContentLikelihood = violentContentLikelihood
	}

	/// - SeeAlso: APIRepresentationConvertible.init(APIRepresentationValue:)
	public init(APIRepresentationValue value: APIRepresentationValue) throws {
		try self.init(
			adultContentLikelihood: value.get("adult"),
			spoofContentLikelihood: value.get("spoof"),
			medicalContentLikelihood: value.get("medical"),
			violentContentLikelihood: value.get("violence")
		)
	}
}

// MARK: -

extension SafeSearchAnnotation: Equatable {}

/// - SeeAlso: Equatable.==
public func == (lhs: SafeSearchAnnotation, rhs: SafeSearchAnnotation) -> Bool {
	return (
		lhs.adultContentLikelihood == rhs.adultContentLikelihood &&
		lhs.spoofContentLikelihood == rhs.spoofContentLikelihood &&
		lhs.medicalContentLikelihood == rhs.medicalContentLikelihood &&
		lhs.violentContentLikelihood == rhs.violentContentLikelihood
	)
}
