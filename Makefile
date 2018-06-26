
.PHONY: build
build:
	pub get
	pub run dart_dev analyze
	pub run dart_dev format --check
	pub run dart_dev test
	pub build extension
	cd build/extension && zip -r ../../extension.zip *

.PHONY: clean
clean:
	rm extension/manifest.json

.PHONY: manifest-chrome
manifest-chrome:
	jq 'del(.applications)' extension/manifest-full.json > extension/manifest.json

.PHONY: manifest-firefox
manifest-firefox:
	cp extension/manifest-full.json extension/manifest.json

.PHONY: quick-build
quick-build:
	pub build extension

.PHONY: release-chrome
release-chrome: manifest-chrome build clean

.PHONY: release-firefox
release-firefox: manifest-firefox build clean
