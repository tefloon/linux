//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

// Adjust this to make the shell smaller or larger
//@ pragma Env QT_SCALE_FACTOR=1

import "./modules/common/"
import "./modules/bar/"
import "./modules/dock/"
import "./modules/mediaControls/"
import "./modules/notificationPopup/"
import "./modules/onScreenDisplay/"
import "./modules/session/"
import "./modules/sidebarRight/"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import "./services/"

ShellRoot {
    // Enable/disable modules here. False = not loaded at all, so rest assured
    // no unnecessary stuff will take up memory if you decide to only use, say, the overview.
    property bool enableBar: true
    property bool enableBackground: false
    property bool enableCheatsheet: false
    property bool enableDock: true
    property bool enableLock: false
    property bool enableMediaControls: true
    property bool enableNotificationPopup: true
    property bool enableOnScreenDisplayBrightness: true
    property bool enableOnScreenDisplayVolume: true
    property bool enableOnScreenKeyboard: false
    property bool enableOverview: false
    property bool enableReloadPopup: false
    property bool enableScreenCorners: false
    property bool enableSession: true
    property bool enableSidebarLeft: false
    property bool enableSidebarRight: true

    // Force initialization of some singletons
    Component.onCompleted: {
        Cliphist.refresh()
        FirstRunExperience.load()
        Hyprsunset.load()
        MaterialThemeLoader.reapplyTheme()
    }

    LazyLoader { active: enableBar; component: Bar {} }
    // LazyLoader { active: enableBackground; component: Background {} }
    // LazyLoader { active: enableCheatsheet; component: Cheatsheet {} }
    LazyLoader { active: enableDock && Config.options.dock.enable; component: Dock {} }
    // LazyLoader { active: enableLock; component: Lock {} }
    LazyLoader { active: enableMediaControls; component: MediaControls {} }
    LazyLoader { active: enableNotificationPopup; component: NotificationPopup {} }
    LazyLoader { active: enableOnScreenDisplayBrightness; component: OnScreenDisplayBrightness {} }
    LazyLoader { active: enableOnScreenDisplayVolume; component: OnScreenDisplayVolume {} }
    // LazyLoader { active: enableOnScreenKeyboard; component: OnScreenKeyboard {} }
    // LazyLoader { active: enableOverview; component: Overview {} }
    // LazyLoader { active: enableReloadPopup; component: ReloadPopup {} }
    // LazyLoader { active: enableScreenCorners; component: ScreenCorners {} }
    LazyLoader { active: enableSession; component: Session {} }
    // LazyLoader { active: enableSidebarLeft; component: SidebarLeft {} }
    LazyLoader { active: enableSidebarRight; component: SidebarRight {} }
}