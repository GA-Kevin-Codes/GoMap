import Foundation
import SwiftUI
import TipKit
import UIKit

final class TipCoordinator {
        static let shared = TipCoordinator()

        private var isConfigured = false
        private var tipStoreStorage: Any?

        private init() {}

        func configureIfNeeded() {
                guard #available(iOS 17.0, *) else { return }
                guard !isConfigured else { return }

                let store = tipStore
                do {
                        try Tips.configure(store.allTips)
                        isConfigured = true
                } catch {
                        NSLog("TipKit configuration failed: %@", error.localizedDescription)
                }
        }

        func showLocationTip(from controller: UIViewController, sourceView: UIView) {
                guard #available(iOS 17.0, *) else { return }
                configureIfNeeded()
                present(tipStore.locationButton, from: sourceView, in: controller, arrow: .down)
        }

        func showOrientationTip(from controller: UIViewController, sourceView: UIView) {
                guard #available(iOS 17.0, *) else { return }
                configureIfNeeded()
                present(tipStore.orientationButton, from: sourceView, in: controller, arrow: .down)
        }

        func showSearchTip(from controller: UIViewController, sourceView: UIView) {
                guard #available(iOS 17.0, *) else { return }
                configureIfNeeded()
                present(tipStore.searchButton, from: sourceView, in: controller, arrow: .down)
        }

        func showMapLayersTip(from controller: UIViewController, sourceView: UIView) {
                guard #available(iOS 17.0, *) else { return }
                configureIfNeeded()
                present(tipStore.mapLayersButton, from: sourceView, in: controller, arrow: .down)
        }

        func showAddButtonTip(from controller: UIViewController, sourceView: UIView) {
                guard #available(iOS 17.0, *) else { return }
                configureIfNeeded()
                present(tipStore.addButton, from: sourceView, in: controller, arrow: .down)
        }

        func showGpxTip(from controller: UIViewController, sourceView: UIView) {
                guard #available(iOS 17.0, *) else { return }
                configureIfNeeded()
                present(tipStore.gpxTraces, from: sourceView, in: controller)
        }

        func showQuestsTip(from controller: UIViewController, sourceView: UIView) {
                guard #available(iOS 17.0, *) else { return }
                configureIfNeeded()
                present(tipStore.quests, from: sourceView, in: controller)
        }

        func showDataOverlayTip(from controller: UIViewController, sourceView: UIView) {
                guard #available(iOS 17.0, *) else { return }
                configureIfNeeded()
                present(tipStore.dataLayers, from: sourceView, in: controller)
        }

        func showAlternateServerTip(from controller: UIViewController, sourceView: UIView) {
                guard #available(iOS 17.0, *) else { return }
                configureIfNeeded()
                present(tipStore.alternateServers, from: sourceView, in: controller)
        }

        @available(iOS 17.0, *)
        private var tipStore: AppTipStore {
                if let store = tipStoreStorage as? AppTipStore {
                        return store
                }
                let store = AppTipStore()
                tipStoreStorage = store
                return store
        }

        @available(iOS 17.0, *)
        private func present<T: Tip>(_ tip: T,
                                     from sourceView: UIView,
                                     in controller: UIViewController,
                                     arrow: UIPopoverArrowDirection = .any)
        {
                guard sourceView.window != nil else { return }
                Task {
                        if await tip.shouldDisplay {
                                await schedulePresentation(tip, from: sourceView, in: controller, arrow: arrow)
                        }
                }
        }

        @available(iOS 17.0, *)
        @MainActor
        private func schedulePresentation<T: Tip>(_ tip: T,
                                                  from sourceView: UIView,
                                                  in controller: UIViewController,
                                                  arrow: UIPopoverArrowDirection) async
        {
                guard controller.viewIfLoaded?.window != nil else { return }
                guard sourceView.window != nil else { return }

                if controller.presentedViewController != nil {
                        try? await Task.sleep(nanoseconds: 600_000_000)
                        await schedulePresentation(tip, from: sourceView, in: controller, arrow: arrow)
                        return
                }

                let tipController = TipViewController(tip)
                tipController.sourceView = sourceView
                tipController.sourceRect = sourceView.bounds
                tipController.permittedArrowDirections = arrow
                controller.present(tipController, animated: true)
        }
}

@available(iOS 17.0, *)
private struct AppTipStore {
        let locationButton = LocationButtonTip()
        let orientationButton = OrientationButtonTip()
        let searchButton = SearchButtonTip()
        let mapLayersButton = MapLayersTip()
        let addButton = AddButtonTip()
        let gpxTraces = GpxTraceTip()
        let quests = QuestsTip()
        let dataLayers = DataLayersTip()
        let alternateServers = AlternateServerTip()

        var allTips: [any Tip] {
                [
                        locationButton,
                        orientationButton,
                        searchButton,
                        mapLayersButton,
                        addButton,
                        gpxTraces,
                        quests,
                        dataLayers,
                        alternateServers
                ]
        }
}

@available(iOS 17.0, *)
private struct LocationButtonTip: Tip {
        var title: Text {
                Text("Re-center the map")
        }

        var message: Text? {
                Text("Tap once to jump to your location and again to follow your heading.")
        }

        var image: Image? {
                Image(systemName: "location.circle")
        }

        var options: [TipOption] {
                [Tips.MaxDisplayCount(1)]
        }
}

@available(iOS 17.0, *)
private struct OrientationButtonTip: Tip {
        var title: Text {
                Text("Stay oriented")
        }

        var message: Text? {
                Text("Use the compass to switch between north-up and heading-up views.")
        }

        var image: Image? {
                Image(systemName: "location.north.line")
        }

        var options: [TipOption] {
                [Tips.MaxDisplayCount(1)]
        }
}

@available(iOS 17.0, *)
private struct SearchButtonTip: Tip {
        var title: Text {
                Text("Find places quickly")
        }

        var message: Text? {
                Text("Search for addresses, places, and presets without leaving the map.")
        }

        var image: Image? {
                Image(systemName: "magnifyingglass")
        }

        var options: [TipOption] {
                [Tips.MaxDisplayCount(1)]
        }
}

@available(iOS 17.0, *)
private struct MapLayersTip: Tip {
        var title: Text {
                Text("Switch map layers")
        }

        var message: Text? {
                Text("Tap for display options or long-press to pick recent imagery.")
        }

        var image: Image? {
                Image(systemName: "square.stack.3d.up")
        }

        var options: [TipOption] {
                [Tips.MaxDisplayCount(1)]
        }
}

@available(iOS 17.0, *)
private struct AddButtonTip: Tip {
        var title: Text {
                Text("Add features faster")
        }

        var message: Text? {
                Text("Tap to add at the crosshairs or drag and long-press for precise placement.")
        }

        var image: Image? {
                Image(systemName: "plus.circle")
        }

        var options: [TipOption] {
                [Tips.MaxDisplayCount(1)]
        }
}

@available(iOS 17.0, *)
private struct GpxTraceTip: Tip {
        var title: Text {
                Text("Record GPX traces")
        }

        var message: Text? {
                Text("Keep the switch on to capture or review your GPS tracks while you map.")
        }

        var image: Image? {
                Image(systemName: "map")
        }

        var options: [TipOption] {
                [Tips.MaxDisplayCount(1)]
        }
}

@available(iOS 17.0, *)
private struct QuestsTip: Tip {
        var title: Text {
                Text("Tackle quests")
        }

        var message: Text? {
                Text("Show quests to discover nearby tasks contributed by the community.")
        }

        var image: Image? {
                Image(systemName: "flag")
        }

        var options: [TipOption] {
                [Tips.MaxDisplayCount(1)]
        }
}

@available(iOS 17.0, *)
private struct DataLayersTip: Tip {
        var title: Text {
                Text("Overlay more data")
        }

        var message: Text? {
                Text("Enable data layers to compare third-party maps and QA overlays while editing.")
        }

        var image: Image? {
                Image(systemName: "square.grid.3x2")
        }

        var options: [TipOption] {
                [Tips.MaxDisplayCount(1)]
        }
}

@available(iOS 17.0, *)
private struct AlternateServerTip: Tip {
        var title: Text {
                Text("Map beyond OSM")
        }

        var message: Text? {
                Text("Pick OpenHistoricalMap or OpenGeofiction to contribute to other communities.")
        }

        var image: Image? {
                Image(systemName: "globe")
        }

        var options: [TipOption] {
                [Tips.MaxDisplayCount(1)]
        }
}
