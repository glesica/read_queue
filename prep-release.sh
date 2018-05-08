#!/bin/sh

pub get
pub run dart_dev analyze
pub run dart_dev format --check
#pub run dart_dev test
pub build extension
cd build/extension && zip -r ../../extension.zip *

