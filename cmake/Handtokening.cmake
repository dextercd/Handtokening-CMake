if(NOT HT_DEFAULT_DESCRIPTION)
    set(HT_DEFAULT_DESCRIPTION "${CMAKE_DESCRIPTION}")
endif()

if(NOT HT_DEFAULT_URL)
    set(HT_DEFAULT_URL "${CMAKE_PROJECT_HOMEPAGE_URL}")
endif()

# Need curl to send/receive the (un)signed programs
find_package(HT_CURL 8.3.0 REQUIRED)

# If osslsigncode or signtool is installed, we can just download the PKCS #7
# signature file and add it to the program instead of transferring the full
# signed program.
find_package(HT_OSSLSIGNCODE 2.0)
if(NOT HT_OSSLSIGNCODE_FOUND)
    # https://vcsjones.dev/custom-authenticode-signing/
    # > Starting in the Windows 10 SDK, two new command line switches are available, dg and di.
    #
    # Well, hopefully that just means any version >= 10. ¯\_(ツ)_/¯
    find_package(HT_SIGNTOOL 10)
endif()

set(HT_ENDPOINT "$ENV{HT_ENDPOINT}" CACHE STRING "URL to submit signing requests to. This normally ends in /api/sign.")
set(HT_USER "$ENV{HT_USER}" CACHE STRING "Username to use for signing authentication.")
set(HT_SECRET "$ENV{HT_SECRET}" CACHE STRING "Password/API key/secret to use for authentication.")
set(HT_SIGNING_PROFILE "$ENV{HT_SIGNING_PROFILE}" CACHE STRING "What signing profile to use.")

set(HT_FIELD_NAMES description url)

function(ht_clear_parts)
    set(HT_FIELD_REGEX PARENT_SCOPE)
    foreach(field IN LISTS HT_FIELD_NAMES)
        string(TOUPPER "${field}" FIELD)
        set("HT_FIELD_${FIELD}" PARENT_SCOPE)
    endforeach()
endfunction()

set(HT_ITEMS)
function(ht_add_item)
    list(APPEND HT_ITEMS "${HT_FIELD_REGEX}")
    foreach(field IN LISTS HT_FIELD_NAMES)
        string(TOUPPER "${field}" FIELD)
        list(APPEND HT_ITEMS "${HT_FIELD_${FIELD}}")
    endforeach()

    set(HT_ITEMS "${HT_ITEMS}" PARENT_SCOPE)
endfunction()

ht_clear_parts()
foreach(item IN LISTS HT_SIGN_PATTERNS)
    set(is_prefix 0)
    foreach(field IN LISTS HT_FIELD_NAMES)
        if (item MATCHES "^${field}=(.*)$")
            if (NOT HT_FIELD_REGEX)
                message(FATAL_ERROR "Expected regex but got ${item}")
            endif()

            string(TOUPPER "${field}" FIELD)

            if(NOT "${HT_FIELD_${FIELD}}" STREQUAL "")
                message(WARNING "Got duplicate field ${field}: '${HT_FIELD_${FIELD}}' and '${CMAKE_MATCH_1}'")
            endif()

            set("HT_FIELD_${FIELD}" "${CMAKE_MATCH_1}")
            set(is_prefix 1)
            break()
        endif()
    endforeach()

    if(NOT is_prefix)
        if(HT_FIELD_REGEX)
            # New regex encountered. This item is done
            ht_add_item()
            ht_clear_parts()
        endif()
        set(HT_FIELD_REGEX ${item})
    endif()
endforeach()

if(HT_FIELD_REGEX)
    ht_add_item()
    ht_clear_parts()
endif()

set(HTPATH "${CMAKE_CURRENT_BINARY_DIR}/HTSign.cmake")
set(HT_SCRATCH "${CMAKE_CURRENT_BINARY_DIR}/HTScratch")
set(HT_PLACEHOLDER_CERT "${Handtokening_CMake_SOURCE_DIR}/placeholder.cer")
file(MAKE_DIRECTORY ${HT_SCRATCH})

configure_file(${Handtokening_CMake_SOURCE_DIR}/HTSign.cmake.in ${HTPATH} @ONLY)

if(HT_ENDPOINT AND HT_USER AND HT_SECRET AND HT_SIGNING_PROFILE)
    set(CPACK_PRE_BUILD_SCRIPTS ${CPACK_PRE_BUILD_SCRIPTS} "${HTPATH}")
else()
    message(WARNING "Handtokening signing not enabled because not all required variables are set.")
endif()
