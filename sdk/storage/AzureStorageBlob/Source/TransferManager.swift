// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import AzureCore
import CoreData

// MARK: Protocols

internal protocol TransferManager: ResumableOperationQueueDelegate {
    // MARK: Properties

    var reachability: ReachabilityManager? { get }
    var persistentContainer: NSPersistentContainer? { get }
    var logger: ClientLogger { get set }
    var delegate: TransferDelegate? { get set }

    // MARK: Storage Methods

    // TODO: Uplevel the relelvant func signatures into TM protocol once reviewed
    // func upload(_ url: URL) -> Transferable
    // func download(_ url: URL) -> Transferable
    // func copy(from source: URL, to destination: URL) -> Transferable

    // MARK: Queue Operations

    var count: Int { get }
    subscript(_: Int) -> Transfer { get }
    var transfers: [Transfer] { get }
    func transfer(withId: UUID) -> Transfer?

    func add(transfer: Transfer)
    func cancel(transfer: Transfer)
    func cancelAll()
    func pause(transfer: Transfer)
    func pauseAll()
    func remove(transfer: Transfer)
    func removeAll()
    func resume(transfer: Transfer)
    func resumeAll()
    func loadContext()
    func saveContext()
}

/// A delegate to receive notifications about state changes for all transfers managed by a `StorageBlobClient`.
public protocol TransferDelegate: AnyObject {
    /// A transfer's state has changed, and progress is being reported.
    func transfer(_: Transfer, didUpdateWithState: TransferState, andProgress: TransferProgress?)
    /// A transfer's state has changed, no progress informating is available.
    func transfer(_: Transfer, didUpdateWithState: TransferState)
    /// A transfer has failed.
    func transfer(_: Transfer, didFailWithError: Error)
    /// A transfer has completed.
    func transferDidComplete(_: Transfer)
    /// Method to return a `BlobStreamUploader` that can be used to complete a transfer.
    func uploader(for transfer: BlobTransfer) -> BlobUploader?
    /// Method to return a `BlobStreamDownloader` that can be used to complete a transfer.
    func downloader(for transfer: BlobTransfer) -> BlobDownloader?
}

// MARK: Extensions

internal extension TransferManager {
    func transfer(withId id: UUID) -> Transfer? {
        return transfers.first { $0.id == id }
    }
}

public extension TransferDelegate {
    func transfer(_ transferParam: Transfer, didUpdateWithState state: TransferState) {
        transfer(transferParam, didUpdateWithState: state, andProgress: nil)
    }
}