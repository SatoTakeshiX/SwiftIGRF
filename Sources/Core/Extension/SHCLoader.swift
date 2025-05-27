import Foundation

extension Bundle {
    public static func loadSHCFile(igrfGen: IGRFGen) -> URL {
        // igrfGenに基づいてSHCファイル名を生成
        let fileName = "IGRF\(igrfGen.rawValue)"

        // ファイル名に一致するパスを探す
        guard let fileURL = Bundle.module.url(forResource: fileName, withExtension: "SHC") else {
            fatalError("Error: File not found at path: \(fileName)")
        }

        return fileURL
    }
}
