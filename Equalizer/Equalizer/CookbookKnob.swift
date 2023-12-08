import AVFoundation
import Controls
import SwiftUI

public struct CookbookKnob: View {
    var text: String
    @Binding var parameter: AUValue
    var range: ClosedRange<AUValue>
    var format: String = "%0.2f"
    

    public init(text: String,
                parameter: Binding<Float>,
                range: ClosedRange<AUValue>) {
        _parameter = parameter
        self.text = text
        self.range = range
    }

    public var body: some View {
        VStack {
            VStack {
                Text(text)
                    .minimumScaleFactor(0.2)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .font(.custom("KRSNA-DREAMER", size: 10))
            }
            .frame(height: 50)
            SmallKnob(value: $parameter, range: range)
        }.frame(maxWidth: 150, maxHeight: 200).frame(minHeight: 100)
    }
}
