//
// NSImage.swift
//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
// Licensed under the MIT License.
//

import AppKit

extension NSImage: Base64EncodableImage {

	/// - SeeAlso: Base64EncodableImage.base64EncodedStringRepresentation()
	@nonobjc public func base64EncodedStringRepresentation() throws -> String {
		guard
			let cgImage = self.CGImageForProposedRect(nil, context: nil, hints: nil),
			data = NSBitmapImageRep(CGImage: cgImage).representationUsingType(.NSPNGFileType, properties: [:])
		else {
			throw Base64EncodableImageError.UnsupportedBitmapData
		}
		return data.base64EncodedStringWithOptions([])
	}

}
