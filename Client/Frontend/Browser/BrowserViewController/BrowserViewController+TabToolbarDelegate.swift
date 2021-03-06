/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared

extension BrowserViewController: TabToolbarDelegate, PhotonActionSheetProtocol {
    func tabToolbarDidPressBack(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        guard let _ = tabManager.selectedTab else { return }
        tabManager.selectedTab?.goBack()
    }

    func tabToolbarDidLongPressBack(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        HapticFeedback.vibrate()
        showBackForwardList()
    }

    func tabToolbarDidPressReload(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        tabManager.selectedTab?.reload()
    }

    func tabToolbarDidPressStop(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        tabManager.selectedTab?.stop()
    }

    func tabToolbarDidPressForward(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        tabManager.selectedTab?.goForward()
    }

    func tabToolbarDidLongPressForward(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        HapticFeedback.vibrate()
        showBackForwardList()
    }

    func tabToolbarDidPressMenu(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        // ensure that any keyboards or spinners are dismissed before presenting the menu
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        // force a modal if the menu is being displayed in compact split screen
        let shouldSuppress = !topTabsVisible && UIDevice.current.isPad
        presentSheetWith(actions: getControlCenterActions(vcDelegate: self), on: self, from: button, suppressPopover: shouldSuppress)
    }

    func tabToolbarDidLongPressMenu(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        guard let tab = self.tabManager.selectedTab, let homePanelURL = NewTabPage.topSites.url else {
            return
        }
        tab.loadRequest(PrivilegedRequest(url: homePanelURL) as URLRequest)
    }

    func tabToolbarDidPressSearch(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        guard let tab = self.tabManager.selectedTab else {
            return
        }
        if tab.isNewTabPage {
            if !self.urlBar.inOverlayMode {
                self.focusLocationTextField(forTab: tab)
            }
        } else if let homePanelURL = NewTabPage.topSites.url {
            tab.loadRequest(PrivilegedRequest(url: homePanelURL) as URLRequest)
        }
    }

    func tabToolbarDidPressTabs(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        showTabTray()
    }

    func getTabToolbarLongPressActionsForModeSwitching() -> [PhotonActionSheetItem] {
        guard let selectedTab = tabManager.selectedTab else { return [] }
        let count = selectedTab.isPrivate ? tabManager.normalTabs.count : tabManager.privateTabs.count
        let infinity = "\u{221E}"
        let tabCount = (count < 100) ? count.description : infinity

        let privateBrowsingMode = PhotonActionSheetItem(title: Strings.ForgetMode.Hotkeys.PrivateBrowsingModeTitle, iconString: "nav-tabcounter", iconType: .TabsButton, tabCount: tabCount) { _ in
            self.tabManager.switchPrivacyMode()
        }
        let normalBrowsingMode = PhotonActionSheetItem(title: Strings.Hotkeys.NormalBrowsingModeTitle, iconString: "nav-tabcounter", iconType: .TabsButton, tabCount: tabCount) { _ in
            self.tabManager.switchPrivacyMode()
        }

        if let tab = self.tabManager.selectedTab {
            return tab.isPrivate ? [normalBrowsingMode] : [privateBrowsingMode]
        }
        return [privateBrowsingMode]
    }

    func getMoreTabToolbarLongPressActions() -> [PhotonActionSheetItem] {
        let newTab = PhotonActionSheetItem(title: Strings.Hotkeys.NewTabTitle, iconString: "quick_action_new_tab", iconType: .Image) { action in
            self.openBlankNewTab(focusLocationField: false, isPrivate: false)}
        let newPrivateTab = PhotonActionSheetItem(title: Strings.Hotkeys.NewPrivateTabTitle, iconString: "quick_action_new_tab", iconType: .Image) { action in
            self.openBlankNewTab(focusLocationField: false, isPrivate: true)}
        let closeTab = PhotonActionSheetItem(title: Strings.Hotkeys.CloseTabTitle, iconString: "tab_close", iconType: .Image) { action in
            if let tab = self.tabManager.selectedTab {
                self.tabManager.removeTabAndUpdateSelectedIndex(tab)
                self.updateTabCountUsingTabManager(self.tabManager)
            }}
        if let tab = self.tabManager.selectedTab {
            return tab.isPrivate ? [newPrivateTab, closeTab] : [newTab, closeTab]
        }
        return [newTab, closeTab]
    }

    func tabToolbarDidLongPressTabs(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        guard self.presentedViewController == nil else {
            return
        }
        var actions: [[PhotonActionSheetItem]] = []
        actions.append(getTabToolbarLongPressActionsForModeSwitching())
        actions.append(getMoreTabToolbarLongPressActions())

        // Force a modal if the menu is being displayed in compact split screen.
        let shouldSuppress = !topTabsVisible && UIDevice.current.isPad

        HapticFeedback.vibrate()

        presentSheetWith(actions: actions, on: self, from: button, suppressPopover: shouldSuppress)
    }

    func showBackForwardList() {
        if let backForwardList = tabManager.selectedTab?.webView?.backForwardList {
            let backForwardViewController = BackForwardListViewController(profile: profile, backForwardList: backForwardList)
            backForwardViewController.tabManager = tabManager
            backForwardViewController.bvc = self
            backForwardViewController.modalPresentationStyle = .overCurrentContext
            backForwardViewController.backForwardTransitionDelegate = BackForwardListAnimator()
            self.present(backForwardViewController, animated: true, completion: nil)
        }
    }

    func showQueriesList(_ view: UIView) {
        HapticFeedback.vibrate()

        self.profile.history.getRecentQueries().uponQueue(.main) { cursor in
            var queries = (cursor.successValue?.asArray() ?? [])
                .unique { $0 }
            queries = Array(queries.prefix(5))

            let queriesItems = self.getQueriesActions(
                queries: queries,
                didSelectQuery: { [weak self] (query) in
                    self?.urlBar.enterOverlayMode(query, pasted: false, search: true)
                },
                didRemoveQuery: { [weak self] (query) in
                    _ = self?.profile.history.removeQuery(query)
                    queries = queries.filter({ $0 != query })
                    if queries.isEmpty {
                        self?.presentedViewController?.dismiss(animated: true)
                    }
                }
            )

            let clearQueryLog = PhotonActionSheetItem(
                title: Strings.Menu.ClearSearchHistory,
                iconString: "menu-burn",
                handler: { [weak self] item in
                    _ = self?.profile.history.clearQueryLog()
                    self?.presentedViewController?.dismiss(animated: true)
                }
            )

            self.presentSheetWith(
                actions: [queriesItems, [clearQueryLog]],
                on: self,
                from: view,
                suppressPopover: !self.topTabsVisible && UIDevice.current.isPad
            )
        }
    }

}
