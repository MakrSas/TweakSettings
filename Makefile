ifeq ($(THEOS_PACKAGE_SCHEME),roothide)
# RootHide needs the roothide/theos fork (https://github.com/roothide/theos)
# the jbroot() API comes from libroothide, the Xcode project is told where to find it
export TARGET = iphone:clang:latest:15.0
export ARCHS = arm64e
TweakSettings_XCODEFLAGS = GCC_PREPROCESSOR_DEFINITIONS='THEOS_PACKAGE_SCHEME_ROOTHIDE=1 $$(inherited)' \
	HEADER_SEARCH_PATHS='$$(inherited) $(THEOS_VENDOR_INCLUDE_PATH)' \
	LIBRARY_SEARCH_PATHS='$$(inherited) $(THEOS_VENDOR_LIBRARY_PATH) $(THEOS_VENDOR_LIBRARY_PATH)/roothide' \
	OTHER_LDFLAGS='$$(inherited) -lroothide'
else ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
export TARGET = iphone:clang:14.4:15.0
export ARCHS = arm64
TweakSettings_XCODEFLAGS = GCC_PREPROCESSOR_DEFINITIONS='THEOS_PACKAGE_INSTALL_PREFIX=\"$(THEOS_PACKAGE_INSTALL_PREFIX)\"'
else
export TARGET = iphone:clang:14.4:10.0
export ARCHS = armv7 arm64
endif

DEBUG = 1
DEBUG_EXT =
FINALPACKAGE = 1
GO_EASY_ON_ME = 0
LEAN_AND_MEAN = 1
THEOS_PACKAGE_DIR = Releases
INSTALL_TARGET_PROCESSES = TweakSettings
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)$(DEBUG_EXT)

include $(THEOS)/makefiles/common.mk

LAUNCH_URL =
XCODEPROJ_NAME = TweakSettings
TweakSettings_XCODEFLAGS += PACKAGE_VERSION='@\"$(THEOS_PACKAGE_BASE_VERSION)\"'
TweakSettings_CODESIGN_FLAGS = -SResources/entitlements.plist

include $(THEOS_MAKE_PATH)/xcodeproj.mk

SUBPROJECTS += TweakSettings-Utility

include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
	$(ECHO_NOTHING)rm -f $(THEOS_STAGING_DIR)/Applications/TweakSettings.app/Localizable.strings$(ECHO_END)
	$(ECHO_NOTHING)/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${THEOS_PACKAGE_BASE_VERSION}" "${THEOS_STAGING_DIR}/Applications/${XCODEPROJ_NAME}.app/Info.plist"$(ECHO_END)
	$(ECHO_NOTHING)/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${PACKAGE_VERSION}" "${THEOS_STAGING_DIR}/Applications/${XCODEPROJ_NAME}.app/Info.plist"$(ECHO_END)
	$(ECHO_BEGIN)$(PRINT_FORMAT_MAGENTA) "Set bundle version to: ${PACKAGE_VERSION}"$(ECHO_END)
	$(ECHO_BEGIN)$(PRINT_FORMAT_MAGENTA) "Built for $(or $(THEOS_PACKAGE_SCHEME),rootful)"$(ECHO_END)

after-install::
ifeq ($(THEOS_PACKAGE_SCHEME),roothide)
	install.exec "killall -9 ${XCODEPROJ_NAME}; uicache -p \"\$$(jbroot /Applications/${XCODEPROJ_NAME}.app)\"; uiopen tweaks:$(LAUNCH_URL)"
else
	install.exec "killall -9 ${XCODEPROJ_NAME}; uicache -p $(THEOS_PACKAGE_INSTALL_PREFIX)/Applications/${XCODEPROJ_NAME}.app; uiopen tweaks:$(LAUNCH_URL)"
endif
