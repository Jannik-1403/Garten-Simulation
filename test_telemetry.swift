import TelemetryClient

func test() {
    var configuration = TelemetryManagerConfiguration(appID: "0DD3FAC2-DC8D-4687-9D13-5E6230EF9D1E")
    configuration.showDebugLogs = true
    TelemetryManager.initialize(with: configuration)
}
