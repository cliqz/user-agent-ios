/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared

class ThirdPartySearchAlerts: UIAlertController {

    /**
    Allows the keyboard to pop back up after an alertview.
    **/
    override var canBecomeFirstResponder: Bool {
        return false
    }

    /**
     Builds the Alert view that asks if the users wants to add a third party search engine.

     - parameter okayCallback: Okay option handler.

     - returns: UIAlertController for asking the user to add a search engine
     **/

    static func addThirdPartySearchEngine(_ okayCallback: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let alert = ThirdPartySearchAlerts(
            title: Strings.Settings.Search.ThirdPartyEngines.AddTitle,
            message: Strings.Settings.Search.ThirdPartyEngines.AddMessage,
            preferredStyle: .alert
        )

        let noOption = UIAlertAction(
            title: Strings.General.CancelString,
            style: .cancel,
            handler: nil
        )

        let okayOption = UIAlertAction(
            title: Strings.General.OKString,
            style: .default,
            handler: okayCallback
        )

        alert.addAction(okayOption)
        alert.addAction(noOption)

        return alert
    }

    /**
     Builds the Alert view that shows the user an error in case a search engine could not be added.

     - returns: UIAlertController with an error dialog
     **/

    static func failedToAddThirdPartySearch() -> UIAlertController {
        return searchAlertWithOK(title: Strings.Settings.Search.ThirdPartyEngines.FailedTitle,
                                 message: Strings.Settings.Search.ThirdPartyEngines.FailedMessage)
    }

    static func incorrectCustomEngineForm() -> UIAlertController {
        return searchAlertWithOK(title: Strings.Settings.Search.ThirdPartyEngines.FormErrorTitle,
                                 message: Strings.Settings.Search.ThirdPartyEngines.FormErrorMessage)
    }

    static func duplicateCustomEngine() -> UIAlertController {
        return searchAlertWithOK(title: Strings.Settings.Search.ThirdPartyEngines.DuplicateErrorTitle,
                                 message: Strings.Settings.Search.ThirdPartyEngines.DuplicateErrorMessage)
    }

    private static func searchAlertWithOK(title: String, message: String) -> UIAlertController {
        let alert = ThirdPartySearchAlerts(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let okayOption = UIAlertAction(
            title: Strings.General.OKString,
            style: .default,
            handler: nil
        )

        alert.addAction(okayOption)
        return alert
    }

}
