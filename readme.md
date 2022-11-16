# Swift `AdaptiveStorage`

This repository hosts a nascent Swift library for file system data storage.
It is build around the [`FileManager`](https://developer.apple.com/documentation/foundation/filemanager)
API.

This library has no connection to CoreData.
Please use CoreData if you feel as though the problem you're solving won't
benefit from file system storage.

I don't recommend using this library for applications other than personal single
user ones.

## The Idea

The simplest way to provide persistent local storage with plain text access thru
the Files app to an application is to use FileManager and enable the
[`UISupportsDocumentBrowser`](https://developer.apple.com/documentation/bundleresources/information_property_list/uisupportsdocumentbrowser)
toggle in the application's property list.

One could approximate having a database by saving a single file, for example a
JSON file, and patch it with each change.

If the application is meant to store binary data as well, the JSON would get too
big and messy keeping the binary contents in as Base64, so in that case, it is
preferrable to store the binaries as their own files and reference them from the
text file(s).

Text-based files backing a large number of data could grow too big, too, though.
Especially, when they are append-only, or the number of records is just too big.

The idea of this package is to provide a file storage abstraction which is used
by an interop layer in the native Swift app and a JavaScript layer used by an
application running within a [`WKWebView`](https://developer.apple.com/documentation/webkit/wkwebview).

The JavaScript application would send a plain object over to the Swift side,
which I think get serialized based on the rules of [`structuredClone`](https://developer.mozilla.org/en-US/docs/Web/API/structuredClone).

See also the [`structuredClone` algorithm](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Structured_clone_algorithm).

The bits that are binary (like array buffers) would get saved to their own files
and the bits that serialize to humand readable text would get saved to a text
file.

On each day, or after each write, or something in between, the library will run
a test and see how long the text file takes to read from the storage.
If this duration grows too large, it will transparently break down the large
single file storing all of the records into a pattern of file per record or
maybe there'll be an intermediate step where archived/hidden files will stay in
one big file and new files will stay in another or get broken down into their
own files.

I need to run some tests and get some numbers to see what is the max reasonable
file size in terms of read and write speed and determine the threshold at which
the breakdown into multiple files should happen.

This value shouldn't be hardcoded, I will instead build the library such that it
determines this value dynamically for each device by running this test daily or
at a different frequency.

This should help optimize the way data is stored and take away the concern out
of the data design in the app.

## To-Do

### Measure approximate durations of basic file system operations on macOS and iOS

In order to be able to get a rough idea of if it even makes sense to split a file
and maybe introduce an index file to speed up the reads and lookups for the size
of data I have in mind, I need to get some numbers.

Measure stuff like:

- How long does it usually take a read and write a text?
  - 1 kB, 1 MB, 1 GB
- How long does it take when also serializing and deserializing from JSON?
  - This will give me a hint of the Swift JSON parser/serializer
- What is the latency of marshalling data over to and from WKWebView
  - This will reveal the speed of the structured clone algorithm
- How long does it take a list a directory?
  - 1 file, 10 files, 100 files, 1000 files, 10000 files, 100000 files
- Is an index file worth having in ordet to look up a record by an ID?
  - Should I store a JSON array of objects as one big file?
  - Should I save the individual objects in their files and have a lookup file?
