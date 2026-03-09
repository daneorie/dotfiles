#!/bin/sh

###############################################################################
### Finder, Dock, & Menu Items                                                #
###############################################################################

echo "Finder: show all filename extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
#defaults write NSGlobalDomain AppleShowAllExtensions -bool false

echo ""
echo "Remove auto-hiding Dock delay"
defaults write com.apple.dock "autohide-delay" -float 0
#defaults delete com.apple.dock "autohide-delay"

echo ""
echo "Speed up display animation"
defaults write com.apple.dock "autohide-time-modifier" -float 0.3
#defaults delete com.apple.dock "autohide-time-modifier"

echo ""
echo "Only show open applications in the Dock"
defaults write com.apple.dock "static-only" -bool true
#defaults delete com.apple.dock "static-only"

echo ""
echo "Display full POSIX path as Finder window title"
#defaults write com.apple.finder "_FXShowPosixPathInTitle" -bool true
#defaults delete com.apple.finder "_FXShowPosixPathInTitle"

echo ""
echo "Disable the warning when changing a file extension"
defaults write com.apple.finder "FXEnableExtensionChangeWarning" -bool false
#defaults delete com.apple.finder "FXEnableExtensionChangeWarning"

echo ""
echo "Minimize windows into their application's icon"
defaults write com.apple.dock "minimize-to-application" -bool true
#defaults delete com.apple.dock "minimize-to-application"

echo ""
echo "Automatically hide and show the Dock"
defaults write com.apple.dock "autohide" -bool true
#defaults write com.apple.dock "autohide" -bool false

echo ""
echo "Don't show recent applications in the Dock"
defaults write com.apple.dock "show-recents" -bool false
#defaults write com.apple.dock "show-recents" -bool true

echo ""
echo "Hide the menu bar"
defaults write "Apple Global Domain" "_HIHideMenuBar" 1
#defaults delete "Apple Global Domain" "_HIHideMenuBar"


###############################################################################
# Safari & WebKit                                                             #
###############################################################################

echo ""
echo "Hiding Safari's sidebar in Top Sites"
defaults write com.apple.Safari ShowSidebarInTopSites -bool false

echo ""
echo "Enabling Safari's debug menu"
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

echo ""
echo "Making Safari's search banners default to Contains instead of Starts With"
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

echo ""
echo "Enabling the Develop menu and the Web Inspector in Safari"
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true

echo ""
echo "Adding a context menu item for showing the Web Inspector in web views"
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true


###############################################################################
# Mail                                                                        #
###############################################################################

echo ""
echo "Setting email addresses to copy as 'foo@example.com' instead of 'Foo Bar <foo@example.com>' in Mail.app"
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false


###############################################################################
# Messages                                                                    #
###############################################################################

echo ""
echo "Disable automatic emoji substitution in Messages.app? (i.e. use plain text smileys) (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false
fi

echo ""
echo "Disable smart quotes in Messages.app? (it's annoying for messages that contain code) (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false
fi

echo ""
echo "Disable continuous spell checking in Messages.app? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false
fi


###############################################################################
### Text Editing / Keyboards                                                  #
###############################################################################

echo ""
# Disable smart quotes and smart dashes
#defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
#defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
#defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool true
#defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool true

echo ""
# Disable auto-correct
#defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
#defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool true

echo ""
# Use function F1, F, etc. keys as standard function keys
#defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true
#defaults write NSGlobalDomain com.apple.keyboard.fnState -bool false


###############################################################################
# Screenshots / Screen                                                        #
###############################################################################

echo ""
# Require password immediately after sleep or screen saver begins"
#defaults write com.apple.screensaver askForPassword -int 1
#defaults write com.apple.screensaver askForPasswordDelay -int 0
#defaults delete com.apple.screensaver askForPassword
#defaults delete com.apple.screensaver askForPasswordDelay

echo ""
# Save screenshots to the Desktop
#defaults write com.apple.screencapture location -string "~/Desktop"
#defaults delete com.apple.screencapture location

echo ""
# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
#defaults write com.apple.screencapture type -string "png"
#defaults delete com.apple.screencapture type

echo ""
# Disable shadow in screenshots
#defaults write com.apple.screencapture disable-shadow -bool true
#defaults delete com.apple.screencapture disable-shadow


###############################################################################
# Address Book, Dashboard, iCal, TextEdit, and Disk Utility                   #
###############################################################################

echo ""
# Use plain text mode for new TextEdit documents
defaults write com.apple.TextEdit RichText -int 0
#defaults delete com.apple.TextEdit RichText


###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

echo ""
# Disable natural scrolling
#defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false


###############################################################################
# Mac App Store                                                               #
###############################################################################

echo ""
# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

echo ""
# Download newly available updates in background
#defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1
#defaults delete com.apple.SoftwareUpdate AutomaticDownload

echo ""
# Install System data files & security updates
#defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1
#defaults delete com.apple.SoftwareUpdate CriticalUpdateInstall


###############################################################################
# Photos                                                                      #
###############################################################################

echo ""
# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
#defaults -currentHost delete com.apple.ImageCapture disableHotPlug

