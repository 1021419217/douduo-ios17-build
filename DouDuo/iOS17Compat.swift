import SwiftUI

// MARK: - iOS 17 兼容层
// 背景：DouDuo 原本 deployment target = 26.0，源码里大量玻璃/滚动边缘等
// iOS 18/26 API 都是裸调用（无 #available 保护）。降到 iOS 17 后编译器要求
// 每个调用点都有可用性检查。本文件提供带 #available 的等价替代，批量替换
// 调用点即可：iOS 26+ 保持原生效果，iOS 17 走无 op 回退（外观降级，功能不变）。

// MARK: Glass 样式（对应系统 Glass 的常用变体）
enum DDGlassStyle {
    case regular
    case regularInteractive
    case regularInteractiveEnabled(Bool)
    case identity
}

// MARK: Shape（对应系统 Shape 的常用变体）
enum DDGlassShape {
    case capsule
    case circle
    case rect(CGFloat) // cornerRadius
}

struct DDGlassModifier: ViewModifier {
    let style: DDGlassStyle
    let shape: DDGlassShape

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            switch (style, shape) {
            case (.regular, .capsule):
                content.glassEffect(.regular, in: .capsule)
            case (.regular, .circle):
                content.glassEffect(.regular, in: .circle)
            case (.regular, .rect(let r)):
                content.glassEffect(.regular, in: .rect(cornerRadius: r))
            case (.regularInteractive, .capsule):
                content.glassEffect(.regular.interactive(), in: .capsule)
            case (.regularInteractive, .circle):
                content.glassEffect(.regular.interactive(), in: .circle)
            case (.regularInteractiveEnabled(let e), .capsule):
                content.glassEffect(.regular.interactive(e), in: .capsule)
            case (.identity, .rect(let r)):
                content.glassEffect(.identity, in: .rect(cornerRadius: r))
            case (.identity, .capsule):
                content.glassEffect(.identity, in: .capsule)
            default:
                content
            }
        } else {
            content
        }
    }
}

extension View {
    /// 兼容 iOS 17 的 glassEffect：iOS 26+ 应用液态玻璃，低版本原样返回
    func ddGlass(_ style: DDGlassStyle, _ shape: DDGlassShape) -> some View {
        modifier(DDGlassModifier(style: style, shape: shape))
    }

    /// 兼容 iOS 17 的 scrollEdgeEffectHidden
    @ViewBuilder
    func ddScrollEdgeHidden(_ hidden: Bool, for edges: Edge.Set) -> some View {
        if #available(iOS 26.0, *) {
            self.scrollEdgeEffectHidden(hidden, for: edges)
        } else {
            self
        }
    }

    /// 兼容 iOS 17 的 toolbarBackgroundVisibility（navigationBar）
    @ViewBuilder
    func ddToolbarBgHiddenNavBar() -> some View {
        if #available(iOS 18.0, *) {
            self.toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        } else {
            self
        }
    }

    /// 兼容 iOS 17 的 toolbarBackgroundVisibility（bottomBar）
    @ViewBuilder
    func ddToolbarBgHiddenBottomBar() -> some View {
        if #available(iOS 18.0, *) {
            self.toolbarBackgroundVisibility(.hidden, for: .bottomBar)
        } else {
            self
        }
    }

    /// 兼容 iOS 17 的 toolbarBackgroundVisibility（navigationBar + bottomBar）
    @ViewBuilder
    func ddToolbarBgHiddenNavAndBottom() -> some View {
        if #available(iOS 18.0, *) {
            self.toolbarBackgroundVisibility(.hidden, for: .navigationBar, .bottomBar)
        } else {
            self
        }
    }

    /// 兼容 iOS 17 的 .buttonStyle(.glassProminent)
    @ViewBuilder
    func ddProminentButtonStyle() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Color.mix（iOS 18+）
extension Color {
    /// 兼容 iOS 17 的 mix(with: .white, by:)
    func ddMixWhite(_ amount: CGFloat) -> Color {
        if #available(iOS 18.0, *) {
            return self.mix(with: .white, by: amount)
        } else {
            // 近似回退：降低不透明度模拟混白
            return self.opacity(1 - amount)
        }
    }
}
