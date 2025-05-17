import XCTest

/// Covers product listing, favoriting, settings, dark mode, and error handling.
final class MarktguruTaskUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        let suiteName = "UITestSuite"
        // Only set the suite name here
        app.launchArguments = ["-UITest_UserDefaultsSuite", suiteName]
    }

    /// Ensures the product list loads and displays at least one product cell.
    @MainActor
    func testProductListLoadsAndDisplaysProducts() {
        app.launch()

        let collection = app.collectionViews["productList"]
        XCTAssertTrue(collection.waitForExistence(timeout: 10), "Product list should appear")

        let firstCell = collection.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10), "First product cell should appear")
    }

    /// Verifies pagination: scrolling loads more products into the list.
    @MainActor
    func testPaginationLoadsMoreProducts() {
        app.launch()

        let collection = app.collectionViews["productList"]
        XCTAssertTrue(collection.waitForExistence(timeout: 10))

        // Scroll to the bottom until more cells appear (assume 10 per page, adjust if needed)
        let initialCount = collection.cells.count
        if initialCount == 0 { XCTFail("No products loaded"); return }

        // Try to scroll to bottom several times, allowing time for load more
        for _ in 0..<3 {
            collection.swipeUp()
            sleep(1) // Let pagination trigger and UI update
        }

        let finalCount = collection.cells.count
        XCTAssertTrue(finalCount > initialCount, "Should load more products when scrolling")
    }

    /// Tests that marking a product as favorite updates the UI appropriately.
    @MainActor
    func testMarkingProductAsFavoriteReflectsInUI() {
        // Clean before first launch
        app.launchArguments.append("-UITest_ResetDefaults")
        app.launch()

        let collection = app.collectionViews["productList"]
        XCTAssertTrue(collection.waitForExistence(timeout: 10))

        let firstCell = collection.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))

        // Tap favorite button (set an accessibilityIdentifier for this in your cell)
        let favoriteButton = firstCell.buttons["favoriteButton"]
        XCTAssertTrue(favoriteButton.exists)
        favoriteButton.tap()

        // Check UI reflects favorite (heart icon filled, or similar)
        XCTAssertTrue(favoriteButton.label == "Unmark as favorite")
    }

    /// Tests that favoriting a product persists across app relaunches.
    @MainActor
    func testFavoritePersistsAfterAppRelaunch() {
        // Clean before first launch
        app.launchArguments.append("-UITest_ResetDefaults")
        app.launch()

        let collection = app.collectionViews["productList"]
        XCTAssertTrue(collection.waitForExistence(timeout: 10))

        let firstCell = collection.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        let favoriteButton = firstCell.buttons["favoriteButton"]
        favoriteButton.tap()

        // Terminate and relaunch app
        app.terminate()
        app.launchArguments.removeAll { $0 == "-UITest_ResetDefaults" }
        app.launch()

        let relaunchedCell = collection.cells.element(boundBy: 0)
        XCTAssertTrue(relaunchedCell.waitForExistence(timeout: 10))
        let relaunchedFavoriteButton = relaunchedCell.buttons["favoriteButton"]
        XCTAssertTrue(relaunchedFavoriteButton.exists)
        XCTAssertEqual(relaunchedFavoriteButton.label, "Unmark as favorite")
    }

    /// Tests that unfavoriting a product updates the UI and persists after relaunch.
    @MainActor
    func testUnfavoritingProductUpdatesAndPersists() {
        // Clean before first launch
        app.launchArguments.append("-UITest_ResetDefaults")
        app.launch()

        let collection = app.collectionViews["productList"]
        XCTAssertTrue(collection.waitForExistence(timeout: 10))

        let firstCell = collection.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        let favoriteButton = firstCell.buttons["favoriteButton"]
        favoriteButton.tap()
        // Check the label is now "Unmark as favorite"
        XCTAssertEqual(favoriteButton.label, "Unmark as favorite")

        // Unfavorite
        favoriteButton.tap()
        // Check the label is now "Mark as favorite"
        XCTAssertEqual(favoriteButton.label, "Mark as favorite")

        // Relaunch app and check still unfavorited
        app.terminate()
        app.launchArguments.removeAll { $0 == "-UITest_ResetDefaults" }
        app.launch()

        let relaunchedCell = collection.cells.element(boundBy: 0)
        let relaunchedFavoriteButton = relaunchedCell.buttons["favoriteButton"]
        // Check the label is now "Mark as favorite"
        XCTAssertEqual(relaunchedFavoriteButton.label, "Mark as favorite")
    }

    /// Ensures the dark mode toggle in Settings works and persists its value after relaunch.
    @MainActor
    func testSettingsToggleWorksAndPersists() {
        // Clean before first launch
        app.launchArguments.append("-UITest_ResetDefaults")
        app.launch()

        // Navigate to Settings tab
        app.tabBars.buttons["Settings"].tap()

        let darkModeSwitch = app.switches["darkModeSwitch"]
        XCTAssertTrue(darkModeSwitch.exists)
        darkModeSwitch.switches.firstMatch.tap()
        XCTAssertEqual(darkModeSwitch.value as? String, "1") // "1" is ON

        // Terminate and relaunch
        app.terminate()
        app.launchArguments.removeAll { $0 == "-UITest_ResetDefaults" }
        app.launch()
        app.tabBars.buttons["Settings"].tap()

        let reloadedSwitch = app.switches["darkModeSwitch"]
        XCTAssertTrue(reloadedSwitch.exists)
        XCTAssertEqual(reloadedSwitch.value as? String, "1") // Still ON
    }

    /// Tests navigation: tapping a product cell shows the detail screen, and you can return back to the list.
    @MainActor
    func testNavigationFromProductListToDetailAndBack() {
        app.launch()

        let collection = app.collectionViews["productList"]
        XCTAssertTrue(collection.waitForExistence(timeout: 10))

        let firstCell = collection.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        firstCell.tap()

        // Assume product detail screen has a unique label or identifier
        let detailTitle = app.staticTexts["productTitleLabel"] // Set in detail view
        XCTAssertTrue(detailTitle.waitForExistence(timeout: 3))

        // Go back
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(collection.cells.element(boundBy: 0).waitForExistence(timeout: 3))
    }

    /// Simulates a network failure and checks that an error message and retry button are shown.
    @MainActor
    func testNetworkFailureShowsErrorState() {
        // Add the launch argument to simulate a network failure.
        app.launchArguments.append("-UITestNetworkFailure")
        app.launch()

        // Wait for the error message label to appear.
        let errorLabel = app.staticTexts["errorMessageLabel"]
        XCTAssertTrue(errorLabel.waitForExistence(timeout: 10), "Should show error message on network failure")

        // Check that the Retry button is present.
        let retryButton = app.buttons["retryButton"]
        XCTAssertTrue(retryButton.exists)

        // Tap Retry and confirm error UI still exists (optional).
        retryButton.tap()
        XCTAssertTrue(errorLabel.waitForExistence(timeout: 5), "Should still show error after retry if network fails")
    }
}
