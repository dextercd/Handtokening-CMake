# Need curl to send/receive the (un)signed programs
find_program(HT_CURL curl REQUIRED)

set(HT_ENDPOINT "$ENV{HT_ENDPOINT}" CACHE STRING "URL to submit signing requests to. This should usually end in /api/sign.")
set(HT_USER "$ENV{HT_USER}" CACHE STRING "Username to use for signing authentication.")
set(HT_SECRET "$ENV{HT_SECRET}" CACHE STRING "Password/API key/secret to use for authentication.")
set(HT_SIGNING_PROFILE "$ENV{HT_SIGNING_PROFILE}" CACHE STRING "What signing profile to use.")

set(PREFIXES description url)

function(clear_parts)
    set(HT_PART_REGEX PARENT_SCOPE)
    foreach(prefix IN LISTS PREFIXES)
        string(TOUPPER "${prefix}" PREFIX)
        set("HT_PART_${PREFIX}" PARENT_SCOPE)
    endforeach()
endfunction()

set(HT_ITEMS)
function(add_item)
    list(APPEND HT_ITEMS "${HT_PART_REGEX}")
    foreach(prefix IN LISTS PREFIXES)
        string(TOUPPER "${prefix}" PREFIX)
        list(APPEND HT_ITEMS "${HT_PART_${PREFIX}}")
    endforeach()

    set(HT_ITEMS "${HT_ITEMS}" PARENT_SCOPE)
endfunction()

clear_parts()
foreach(item IN LISTS HT_SIGN_PATTERNS)
    set(is_prefix 0)
    foreach(prefix IN LISTS PREFIXES)
        if (item MATCHES "^${prefix}=\"(.*)\"$" )
            if (NOT HT_PART_REGEX)
                message(FATAL_ERROR "Expected regex but got ${item}")
            endif()

            string(TOUPPER "${prefix}" PREFIX)

            if(NOT "${HT_PART_${PREFIX}}" STREQUAL "")
                message(WARNING "Got duplicate part ${prefix}: '${HT_PART_${PREFIX}}' and '${CMAKE_MATCH_1}'")
            endif()

            set("HT_PART_${PREFIX}" "${CMAKE_MATCH_1}")
            set(is_prefix 1)
            break()
        endif()
    endforeach()

    if(NOT is_prefix)
        if(HT_PART_REGEX)
            # New regex encountered. This item is done
            add_item()
            clear_parts()
        endif()
        set(HT_PART_REGEX ${item})
    endif()
endforeach()

if(HT_PART_REGEX)
    add_item()
    clear_parts()
endif()

set(HTPATH "${CMAKE_CURRENT_BINARY_DIR}/HTSign.cmake")
set(HT_SCRATCH "${CMAKE_CURRENT_BINARY_DIR}/HTScratch")
file(MAKE_DIRECTORY ${HT_SCRATCH})

configure_file(${CMAKE_CURRENT_LIST_DIR}/HTSign.cmake.in ${HTPATH} @ONLY)

if(HT_ENDPOINT AND HT_USER AND HT_SECRET AND HT_SIGNING_PROFILE)
    list(APPEND CPACK_PRE_BUILD_SCRIPTS ${HTPATH})
else()
    message(WARNING "Handtokening signing not enabled because not all required variables are set.")
endif()
