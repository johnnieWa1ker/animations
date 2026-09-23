import SwiftUI

/// Standalone deterministic checks; this Playgrounds app has no test target.
@main
struct IceSimulationChecks {
    @MainActor static func main() {
        let settings = IceSettings()
        var ice = IceSimulation()
        for _ in 0..<600 { ice.advance(dt: 1 / 60, settings: settings, aspect: 0.75) }
        precondition(ice.season == 1 && !ice.needsAdvance(settings: settings), "Freeze must settle")

        ice.finger = SIMD2(0.5, 0.5)
        for _ in 0..<60 { ice.advance(dt: 1 / 60, settings: settings, aspect: 0.75) }
        precondition(ice.deposits.count == 1 && ice.deposits[0].strength > 1, "Holding must accumulate heat")
        precondition(ice.shaderTouches.count == ice.deposits.count * 4, "Shader ABI is float4 per deposit")

        ice.finger = nil
        settings.refreezes = false
        let frozenAge = ice.deposits[0].age
        for _ in 0..<600 { ice.advance(dt: 1 / 60, settings: settings, aspect: 0.75) }
        precondition(ice.deposits[0].age == frozenAge, "Disabled refreeze must retain heat")
        settings.refreezes = true
        for _ in 0..<600 { ice.advance(dt: 1 / 60, settings: settings, aspect: 0.75) }
        precondition(ice.deposits.isEmpty, "Old touch samples must expire")

        settings.refreezes = false
        for y in 0..<30 {
            for x in 0..<30 {
                ice.finger = SIMD2(Float(x) / 29, Float(y) / 29)
                ice.advance(dt: 0.05, settings: settings, aspect: 0.75)
            }
        }
        precondition(ice.deposits.count == 160, "Heat history must stay bounded")
        precondition(ice.shaderTouches.allSatisfy(\.isFinite), "Shader inputs must remain finite")
        ice.finger = nil
        settings.melts = true
        for _ in 0..<600 { ice.advance(dt: 1 / 60, settings: settings, aspect: 0.75) }
        precondition(ice.season == 0, "Melt must clear the full layer")
        ice.reset()
        precondition(ice.season == 0 && ice.deposits.isEmpty && ice.finger == nil, "Reset must clear all state")

        print("PASS: freeze, idle, stationary heat, shader ABI, refreeze off/on, bounded history, melt, reset")
    }
}
