import MapKit
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ISSViewModel()

    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.annotations) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    VStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                        Text("ISS")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.7))
                            .clipShape(Capsule())
                    }
                }
            }
            .ignoresSafeArea()

            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("International Space Station")
                            .font(.headline)
                        Text(viewModel.statusText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button {
                        Task { await viewModel.refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Refresh")
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)

                Spacer()

                VStack(alignment: .leading, spacing: 10) {
                    dataRow(title: "Latitude", value: viewModel.formattedLatitude)
                    dataRow(title: "Longitude", value: viewModel.formattedLongitude)
                    dataRow(title: "Altitude", value: viewModel.formattedAltitude)
                    dataRow(title: "Velocity", value: viewModel.formattedVelocity)
                    dataRow(title: "Source", value: "Celestrak")
                    dataRow(title: "Timestamp", value: viewModel.formattedTimestamp)
                }
                .font(.subheadline)
                .padding(16)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .task {
            await viewModel.refresh()
        }
        .onReceive(viewModel.timer) { _ in
            Task { await viewModel.refresh() }
        }
    }

    private func dataRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    ContentView()
}
