// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import XCTest

@testable import Benchmark

final class BenchmarkReporterTests: XCTestCase {
    func assertIsPrintedAs(_ results: [BenchmarkResult], _ expected: String) {
        let output = MockTextOutputStream()
        var reporter = PlainTextReporter(to: output)

        reporter.report(results: results)

        let expectedLines = expected.split(separator: "\n").map { String($0) }
        let actual = output.lines.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        for (expectedLine, actualLine) in zip(expectedLines, actual) {
            XCTAssertEqual(expectedLine, actualLine)
        }
    }

    func testPlainTextReporter() throws {
        let results: [BenchmarkResult] = [
            BenchmarkResult(
                benchmarkName: "fast", suiteName: "MySuite",
                settings: BenchmarkSettings(),
                measurements: [1_000, 2_000],
                warmupMeasurements: [],
                counters: [:]),
            BenchmarkResult(
                benchmarkName: "slow", suiteName: "MySuite",
                settings: BenchmarkSettings(),
                measurements: [1_000_000, 2_000_000],
                warmupMeasurements: [],
                counters: [:]),
        ]
        let expected = #"""
            name         time         std        iterations
            -----------------------------------------------
            MySuite.fast    1500.0 ns ±  47.14 %          2
            MySuite.slow 1500000.0 ns ±  47.14 %          2
            """#
        assertIsPrintedAs(results, expected)
    }

    func testCountersAreReported() throws {
        let results: [BenchmarkResult] = [
            BenchmarkResult(
                benchmarkName: "fast", suiteName: "MySuite",
                settings: BenchmarkSettings(),
                measurements: [1_000, 2_000],
                warmupMeasurements: [],
                counters: ["foo": 7]),
            BenchmarkResult(
                benchmarkName: "slow", suiteName: "MySuite",
                settings: BenchmarkSettings(),
                measurements: [1_000_000, 2_000_000],
                warmupMeasurements: [],
                counters: [:]),
        ]
        let expected = #"""
            name         time         std        iterations foo
            ---------------------------------------------------
            MySuite.fast    1500.0 ns ±  47.14 %          2 7.0
            MySuite.slow 1500000.0 ns ±  47.14 %          2
            """#
        assertIsPrintedAs(results, expected)
    }

    func testWarmupReported() throws {
        let results: [BenchmarkResult] = [
            BenchmarkResult(
                benchmarkName: "fast", suiteName: "MySuite",
                settings: BenchmarkSettings(),
                measurements: [1_000, 2_000],
                warmupMeasurements: [10, 20, 30],
                counters: [:]),
            BenchmarkResult(
                benchmarkName: "slow", suiteName: "MySuite",
                settings: BenchmarkSettings(),
                measurements: [1_000_000, 2_000_000],
                warmupMeasurements: [],
                counters: [:]),
        ]
        let expected = #"""
            name         time         std        iterations warmup
            -------------------------------------------------------
            MySuite.fast    1500.0 ns ±  47.14 %          2 60.0 ns
            MySuite.slow 1500000.0 ns ±  47.14 %          2
            """#
        assertIsPrintedAs(results, expected)
    }

    func testTimeUnitReported() throws {
        let results: [BenchmarkResult] = [
            BenchmarkResult(
                benchmarkName: "ns", suiteName: "MySuite",
                settings: BenchmarkSettings([TimeUnit(.ns)]),
                measurements: [123_456_789],
                warmupMeasurements: [],
                counters: [:]),
            BenchmarkResult(
                benchmarkName: "us", suiteName: "MySuite",
                settings: BenchmarkSettings([TimeUnit(.us)]),
                measurements: [123_456_789],
                warmupMeasurements: [],
                counters: [:]),
            BenchmarkResult(
                benchmarkName: "ms", suiteName: "MySuite",
                settings: BenchmarkSettings([TimeUnit(.ms)]),
                measurements: [123_456_789],
                warmupMeasurements: [],
                counters: [:]),
            BenchmarkResult(
                benchmarkName: "s", suiteName: "MySuite",
                settings: BenchmarkSettings([TimeUnit(.s)]),
                measurements: [123_456_789],
                warmupMeasurements: [],
                counters: [:]),
        ]
        let expected = #"""
            name       time           std        iterations
            -----------------------------------------------
            MySuite.ns 123456789.0 ns ±   0.00 %          1
            MySuite.us  123456.789 us ±   0.00 %          1
            MySuite.ms  1234.56789 ms ±   0.00 %          1
            MySuite.s   0.123456789 s ±   0.00 %          1
            """#
        assertIsPrintedAs(results, expected)
    }

    static var allTests = [
        ("testPlainTextReporter", testPlainTextReporter),
        ("testCountersAreReported", testCountersAreReported),
        ("testWarmupReported", testWarmupReported),
        ("testTimeUnitReported", testTimeUnitReported),
    ]
}
