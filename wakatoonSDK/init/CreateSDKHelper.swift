 //
//  CreateSDKHelper.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 09/12/22.
//


//MARK: - CREATE A SDK -

/*
  -------- iphoneos -- not in use
 
 xcodebuild archive \
 -scheme wakatoonSDK \
 -destination "generic/platform=iOS" \
 -archivePath ../output/wakatoonSDK-iOS \
 SKIP_INSTALL=NO \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES
 
 
 xcodebuild archive \
 -scheme wakatoonSDK \
 -destination "generic/platform=iOS Simulator" \
 -archivePath ../output/wakatoonSDK-Sim \
 SKIP_INSTALL=NO \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES
 
 
 cd ..
 
 cd output
 
 xcodebuild -create-xcframework \
 -framework ./wakatoonSDK-iOS.xcarchive/Products/Library/Frameworks/wakatoonSDK.framework \
 -framework ./wakatoonSDK-Sim.xcarchive/Products/Library/Frameworks/wakatoonSDK.framework \
 -output ./WakatoonSDK.xcframework
 
 
 
 -framework ./wakatoonSDK-Ipad.xcarchive/Products/Library/Frameworks/wakatoonSDK.framework \
 -framework ./wakatoonSDK--Ipad-Sim.xcarchive/Products/Library/Frameworks/wakatoonSDK.framework \
 
 xcodebuild archive \
 -scheme wakatoonSDK \
 -destination "generic/platform=iPadOS" \
 -archivePath ../output/wakatoonSDK-Ipad \
 SKIP_INSTALL=NO \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES
 
 
 xcodebuild archive \
 -scheme wakatoonSDK \
 -destination "generic/platform=iPadOS Simulator" \
 -archivePath ../output/wakatoonSDK-Ipad-Sim \
 SKIP_INSTALL=NO \
 BUILD_LIBRARY_FOR_DISTRIBUTION=YES
 
 */


//MARK: - INITIALIZER OF SDK -

/*

 WakatoonManager.shared.setupSDK(CLIENT_ID: "", API_KEY: "JJkc8KaGCH74saWE0smP28oR6LvUpmiEtOjCDsQd", window: self.window ?? UIWindow())
 
 */

//MARK: - -

