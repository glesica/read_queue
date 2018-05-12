# Sooner or Later

A Chrome extension that allows the user to maintain a queue of pages or
articles to read in the future. The goal is to clean up the mass of tabs
that many people keep open and help the user stay on top of his or her
reading list.

## Development

The extension is written in [Dart](https://www.dartlang.org/). Assuming
a working Dart setup, `pub get` will get the dependencies and
`pub build extension` will build the extension. Compiled output
will end up in `build/extension/`.

To prepare a new release for submission to the Chrome or Mozilla
extension repositories, use the `prep-release.sh` script.

## Credits

  * Icon by [Kirby Wu](https://thenounproject.com/tkirby/) and licensed
    [CC-BY](https://creativecommons.org/licenses/by/4.0/).
