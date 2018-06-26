# Sooner or Later

A Chrome extension that allows the user to maintain a queue of pages or
articles to read in the future. The goal is to clean up the mass of tabs
that many people keep open and help the user stay on top of his or her
reading list.

## Development

The extension is written in [Dart](https://www.dartlang.org/). Assuming
a working Dart setup, `pub get` will get the dependencies and `make manifest-X
quick-build` will give you a working manifest (see below) and build the
extension so you can run it unpacked. Compiled output will end up in
`build/extension/`.

There are some other useful make targets:

  * `make release-chrome` - build a release for Chrome (`extension.zip`)
  * `make release-firefox` - build a release for Firefox (`extension.zip`)

For development, the following targets configure the manifest file
correctly, depending on the browser you want to use for testing:

  * `make manifest-chrome`
  * `make manifest-firefox`

## Credits

  * Icon by [Kirby Wu](https://thenounproject.com/tkirby/) and licensed
    [CC-BY](https://creativecommons.org/licenses/by/4.0/).
