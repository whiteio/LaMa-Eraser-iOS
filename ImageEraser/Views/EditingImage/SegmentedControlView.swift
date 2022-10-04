import SwiftUI

struct SegmentedControlView: View {
    @Binding private var selectedIndex: Int

    private let items: [(String, String)]

    init(selectedIndex: Binding<Int>, items: [(String, String)]) {
        _selectedIndex = selectedIndex
        self.items = items
    }

    var body: some View {
        VStack {
            SegmentedControlButtonView(selectedIndex: $selectedIndex,
                                       items: items)
        }
        .cornerRadius(12)
    }
}

private struct SegmentedControlButtonView: View {
    @Binding private var selectedIndex: Int

    private let items: [(String, String)]

    init(selectedIndex: Binding<Int>,
         items: [(String, String)])
    {
        _selectedIndex = selectedIndex

        self.items = items
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { index in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        selectedIndex = index
                    }
                }, label: {
                    HStack {
                        VStack {
                            Image(systemName: items[index].1)
                                .frame(width: 25, height: 25)
                                .foregroundColor(selectedIndex == index ? .black : .white)
                            Text(items[index].0)
                                .foregroundColor(selectedIndex == index ? .black : .white)
                        }
                    }
                    .padding(EdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20))
                })
                .background(selectedIndex == index ? .white : .black.opacity(0.4))
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(Color.black.opacity(0.4))
        .shadow(radius: 12)
        .foregroundColor(.white)
    }
}

struct SegmentedControlView_Previews: PreviewProvider {
    @State static var selectedIndex = 0
    static var previews: some View {
        SegmentedControlView(selectedIndex: $selectedIndex,
                             items: [
                                 ("Test", "plus.magnifyingglass"),
                                 ("Test", "plus.magnifyingglass"),
                             ])
    }
}
