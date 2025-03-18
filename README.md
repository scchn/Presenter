# Presenter

A lightweight SwiftUI library that bridges UIKit's modal presentation capabilities to SwiftUI.

## Usage

### Basic Usage

```swift
import Presenter

struct ContentView: View {
    @State private var showModal = false
    
    var body: some View {
        Button("Show Modal") {
            showModal = true
        }
        .presenter(isPresented: $showModal) {
            Text("Modal Content")
                .padding()
                .background(Color.white)
                .cornerRadius(10)
        }
    }
}
```

### With Item Binding

```swift
@State private var selectedItem: String? = nil

Button("Show Item") {
    selectedItem = "Selected Item"
}
.presenter(item: $selectedItem) { item in
    Text("You selected: \(item)")
        .padding()
}
```

### Customizing Presentation Style

```swift
.presenter(
    isPresented: $showModal,
    presentationStyle: .formSheet,
    transitionStyle: .flipHorizontal
) {
    ModalView()
}
```

### Using Popover

```swift
.popoverPresenter(isPresented: $showPopover) {
    Text("Popover Content")
        .padding()
}
```

### Dismissing From Inside the Modal

```swift
struct Modal: View {
    @Environment(\.dismissPresenter) private var dismiss
    var message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text(message)
                .font(.title.bold())
                .foregroundStyle(.red)
            
            Button("OK") {
                dismiss()
            }
            .foregroundStyle(.white)
        }
        .padding(40)
        .background(.indigo)
        .clipShape(.rect(cornerRadius: 8))
    }
}

struct ContentView: View {
    @State private var presentedMessage: String?
    
    var body: some View {
        Color.teal
            .ignoresSafeArea()
            .overlay {
                Button("Present") {
                    presentedMessage = "Error!"
                }
                .foregroundStyle(.white)
            }
            .presenter(
                item: $presentedMessage,
                presentationStyle: .overFullScreen
            ) { message in
                Modal(message: message)
            }
    }
}
```
