find_program(HT_CURL curl)

if(HT_CURL)
    execute_process(COMMAND ${HT_CURL} --version
        OUTPUT_VARIABLE curl_version_output
        ERROR_VARIABLE curl_version_error
        RESULT_VARIABLE curl_version_result
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT curl_version_result EQUAL 0)
        message(SEND_ERROR "Command failed: ${HT_CURL} --version:\n${curl_version_error}")
    else()
        if(curl_version_output MATCHES "^curl ([0-9]+[.][0-9]+[.][0-9]+)")
            set(HT_CURL_VERSION "${CMAKE_MATCH_1}")
        else()
            message(SEND_ERROR "Couldn't get version number from ${HT_CURL} --version:\n${curl_version_output}")
        endif()
    endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(HT_CURL
    REQUIRED_VARS HT_CURL HT_CURL_VERSION
    VERSION_VAR HT_CURL_VERSION
)

if(HT_CURL AND NOT HT_CURL_FOUND)
    set(HT_CURL 0 CACHE STRING "" FORCE)
endif()
