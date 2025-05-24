import Foundation
import IGRFCore

// IGRF合成プログラムの説明文を表示する関数
func displayIGRFIntroduction() {
    print(" ")
    print("******************************************************")
    print("*              IGRF SYNTHESIS PROGRAM                *")
    print("*                                                    *")
    print("* A program for the computation of geomagnetic       *")
    print("* field elements from the International Geomagnetic  *")
    print("* Reference Field (14th generation) as revised in    *")
    print("* December 2024 by the IAGA Working Group V-MOD.     *")
    print("*                                                    *")
    print("* It is valid for dates from 1900.0 to 2030.0;       *")
    print("* values up to 2035.0 will be computed with          *")
    print("* reduced accuracy. Values for dates before 1945.0   *")
    print("* and after 2020.0 are non-definitive, otherwise     *")
    print("* the values are definitive.                         *")
    print("*                                                    *")
    print("*                                                    *")
    print("*            (on behalf of) IAGA Working Group V-MOD *")
    print("******************************************************")
    print(" ")
    print("Enter number of require IGRF generation (1 to 14)")
    print("or press \"Return\" for IGRF-14")
}

displayIGRFIntroduction()

print("Enter generation number: ")
var igrfGenNumber: Int = 14

if let input = readLine() {
    if input.isEmpty {
        print("No input. Using IGRF-14 ")
        igrfGenNumber = 14
    } else if let inputNumber = Int(input) {
        if inputNumber >= 1 && inputNumber <= 14 {
            igrfGenNumber = inputNumber
        } else {
            var validInput = false
            while !validInput {
                print("Enter generation number: ")
                if let newInput = readLine(), let newNumber = Int(newInput) {
                    if newNumber >= 1 && newNumber <= 14 {
                        igrfGenNumber = newNumber
                        validInput = true
                    }
                }
            }
        }
    } else {
        print("\(input) is an invalid input. Using IGRF-14 as default.")
        igrfGenNumber = 14
    }
}

// Load IGRF coefficient file based on selected generation
let fileManager = FileManager.default

// プロジェクトのルートディレクトリを取得
let currentDirectory = fileManager.currentDirectoryPath
let igrfFilePath = "\(currentDirectory)/SHC_files/IGRF\(igrfGenNumber).SHC"
print("Loading IGRF coefficient file: \(igrfFilePath)")

var igrfData: IGRFModel?

guard let igrfGen = IGRFGen(rawValue: igrfGenNumber) else {
    print("Error: Invalid IGRF generation number")
    exit(1)
}

let shcURL = Bundle.loadSHCFile(igrfGen: igrfGen)
igrfData = IGRFUtils.loadSHCFile(filepath: shcURL.path)
print("Successfully loaded IGRF-\(igrfGen.rawValue) coefficients")

guard let igrfData = igrfData else {
    print("Error: Failed to load IGRF coefficient file")
    exit(1)
}

print("Enter name of output file")
print("or press 'Return' for output to screen")

var outputFilename: String? = nil

print("Enter filename: ", terminator: "")
if let input = readLine() {
    if input.isEmpty {
        print("Printing to screen")
    } else {
        outputFilename = input
        print(input)
    }
}

var iopt: Int = 0

while true {
    print("Choose an option:")
    print("1 - values at one location and date")
    print("2 - values at yearly intervals at one location")
    print("3 - values on a latitude/longitude grid at one date")
    print("->", terminator: "")

    if let input = readLine(), let option = Int(input) {
        if option >= 1 && option <= 3 {
            iopt = option
            break
        }
    }
}

if iopt == 1 {
    let singlePointTime = SinglePointTime()
    let input = singlePointTime.input()

    let synthesizer = MagneticFieldSynthesizer()
    let result = synthesizer.synthesize(input: input, igrfData: igrfData)
    singlePointTime.output(
        fileName: outputFilename, input: input, result: result, igrfGen: igrfGenNumber)

} else if iopt == 2 {
    _ = IOOptions.option2()
    fatalError("Not implemented")

} else if iopt == 3 {
    _ = IOOptions.option3()
    fatalError("Not implemented")
}
