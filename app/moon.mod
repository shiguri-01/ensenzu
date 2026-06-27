// Learn more about moon.mod configuration:
// https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html
//
// To add a dependency, run this command in your terminal:
//   moon add moonbitlang/x
//
// Or manually declare it in `import`, for example:
import {
  "shiguri-01/ensenzu@0.1.0",
  "moonbit-community/rabbita@0.12.4",
}

name = "shiguri-01/app"

version = "0.1.0"

readme = "README.md"

repository = ""

license = "Apache-2.0"

keywords = [ ]

preferred_target = "js"

supported_targets = "js"

description = ""

options(
  source: "src",
)
