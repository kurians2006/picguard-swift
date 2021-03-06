#
# Picguard.podspec
#
# Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
# Licensed under the MIT License.
#

Pod::Spec.new do |spec|

  # Description

  spec.name = 'Picguard'
  spec.version = '0.3'
  spec.summary = 'Image analysis framework for Swift'
  spec.homepage = 'https://github.com/netguru/picguard-swift'

  # License

  spec.license = {
    type: 'MIT',
    file: 'LICENSE.md'
  }

  spec.authors = {
    'Adrian Kashivskyy' => 'adrian.kashivskyy@netguru.co',
    'Łukasz Wolańczyk' => 'lukasz.wolanczyk@netguru.co'
  }

  # Source

  spec.source = {
    git: 'https://github.com/netguru/picguard-swift.git',
    tag: spec.version.to_s
  }

  spec.source_files = 'Sources'

  spec.ios.exclude_files = 'Sources/NSImage.swift'
  spec.osx.exclude_files = 'Sources/UIImage.swift'

  # Settings

  spec.requires_arc = true

  spec.ios.deployment_target = '9.0'
  spec.osx.deployment_target = '10.11'

  # Linking

  spec.frameworks = 'Foundation'

  spec.ios.frameworks = 'UIKit'
  spec.osx.frameworks = 'AppKit'

end
