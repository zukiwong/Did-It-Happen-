import SwiftUI

enum AppScreen {
    case splash
    case traceChecklist
    case traceReport
    case selfRiskCheck
    case selfReflection
    case sanctuary
    case archiveAccess
    case archive
}

struct AppNavigator: View {
    @State private var store  = InvestigationStore()
    @State private var stack  : [AppScreen] = [.splash]

    private var current: AppScreen { stack.last ?? .splash }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            screenView(current)
                .transition(.opacity)
                .id(current)
        }
        .animation(.easeInOut(duration: 0.3), value: current)
        .environment(store)
    }

    @ViewBuilder
    private func screenView(_ screen: AppScreen) -> some View {
        switch screen {
        case .splash:
            SplashScreen { choice in
                switch choice {
                case .partner:
                    store.startSession(entryType: "partner")
                    push(.traceChecklist)
                case .self:
                    store.startSession(entryType: "self")
                    push(.selfRiskCheck)
                case .records:
                    push(.archiveAccess)
                }
            }

        case .traceChecklist:
            TraceChecklistScreen(onBack: pop, onNext: { push(.traceReport) })

        case .traceReport:
            TraceReportScreen(onBack: pop)

        case .selfRiskCheck:
            SelfRiskCheckScreen(onBack: pop, onComplete: { push(.selfReflection) })

        case .selfReflection:
            SelfReflectionScreen(
                onBack: pop,
                onChat: { push(.sanctuary) },
                onExit: replaceWithSplash
            )

        case .sanctuary:
            MindSanctuaryScreen(onBack: pop)

        case .archiveAccess:
            ArchiveAccessScreen(onBack: pop, onSuccess: { push(.archive) })

        case .archive:
            TraceArchiveScreen(onBack: pop)
        }
    }

    private func push(_ screen: AppScreen) {
        var s = stack
        s.append(screen)
        withAnimation(.easeInOut(duration: 0.3)) { stack = s }
    }

    private func pop() {
        guard stack.count > 1 else { return }
        var s = stack
        s.removeLast()
        withAnimation(.easeInOut(duration: 0.3)) { stack = s }
    }

    private func replaceWithSplash() {
        withAnimation(.easeInOut(duration: 0.3)) { stack = [.splash] }
    }
}
