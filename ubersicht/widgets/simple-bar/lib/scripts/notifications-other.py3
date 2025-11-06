#!/usr/bin/env /opt/homebrew/Cellar/python@3.11/3.11.13/Frameworks/Python.framework/Versions/3.11/bin/python3.11
#ref: https://gist.github.com/pudquick/eebc4d569100c8e3039bf3eae56bee4c

from Foundation import NSBundle
import objc
CoreServices = NSBundle.bundleWithIdentifier_('com.apple.CoreServices')

functions = [
    ('_LSCopyRunningApplicationArray', b'@I'),
    ('_LSCopyApplicationInformation', b'@I@@'),
]

constants = [
    ('_kLSDisplayNameKey', b'@'),
]

objc.loadBundleFunctions(CoreServices, globals(), functions)
objc.loadBundleVariables(CoreServices, globals(), constants)


kLSDefaultSessionID = 0xfffffffe # The actual value is `int -2`
badge_label_key = "StatusLabel" # TODO: Is there a `_kLS*` constant for this?

app_asns = _LSCopyRunningApplicationArray(kLSDefaultSessionID)
app_infos = [_LSCopyApplicationInformation(kLSDefaultSessionID, asn, None) for asn in app_asns]

app_badges = { app_info.get(_kLSDisplayNameKey): app_info[badge_label_key].get("label", None)
    for app_info in app_infos if badge_label_key in app_info }

print(app_badges)
