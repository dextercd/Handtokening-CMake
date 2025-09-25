# Handtokening-CMake

Module to sign program files with Handtokening during the CPack packaging step.

## Usage

Just before `include(CPack)` add:

```cmake
FetchContent_Declare(
    Handtokening_CMake
    GIT_REPOSITORY https://github.com/dextercd/Handtokening-CMake.git
    GIT_TAG [Version hash here]
)
FetchContent_MakeAvailable(Handtokening_CMake)

set(HT_SIGN_PATTERNS
    "Debug/noita_dear_imgui\\.dll$" "description=Noita Dear ImGui module (Debug Build)"
    "noita_dear_imgui\\.dll$"       "description=Noita Dear ImGui module"
    "native_test\\.dll$"            "description=Noita Dear ImGui example native mod module"
)
include(Handtokening)
```

The `HT_SIGN_PATTERNS` variable defines what you want to sign.
You can provide `description` and `url` attributes after a pattern which will then be included in the Authenticode signature data.

The module requires the following cache variables before it attempts to sign programs:

* `HT_ENDPOINT`: URL to submit signing requests to. This normally ends in /api/sign.
* `HT_USER`: Client name to authenticate as.
* `HT_SECRET`: API authentication secret.
* `HT_SIGNING_PROFILE`: What signing profile to use.

It's expected that these are defined outside the code base as part of the CI setup.

If they're not provided as cache variables,
then the module will try to create cache variables from environment variables with the same name.

## License

Copyright 2025 Dexter Castor Döpping

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this program except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
