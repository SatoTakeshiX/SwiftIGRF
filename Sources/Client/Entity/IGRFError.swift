public enum IGRFError: Error {
    case failedToLoadSHCFile
    case invalidAltitude(message: String)
    case invalidDate(message: String)
}
