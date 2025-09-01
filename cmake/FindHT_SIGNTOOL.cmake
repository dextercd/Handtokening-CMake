find_program(HT_SIGNTOOL signtool.exe)

if(HT_SIGNTOOL)
    cmake_path(NATIVE_PATH HT_SIGNTOOL COMMAND_PATH)

    # WMIC expects a path with doubled up backslashes
    string(REPLACE [[\]] [[\\]] COMMAND_PATH "${COMMAND_PATH}")
    execute_process(COMMAND wmic datafile where "name=\"${COMMAND_PATH}\"" get version
        OUTPUT_VARIABLE signtool_version_output
        ERROR_VARIABLE signtool_version_error
        RESULT_VARIABLE signtool_version_result
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT signtool_version_result EQUAL 0)
        message(SEND_ERROR "wmic get version command failed.")
        message(SEND_ERROR "stdout: ${signtool_version_output}")
        message(SEND_ERROR "stderr: ${signtool_version_error}")
    else()
        if(signtool_version_output MATCHES "\n([0-9]+[.][0-9]+[.][0-9]+[.][0-9]+)")
            set(HT_SIGNTOOL_VERSION "${CMAKE_MATCH_1}")
        else()
            message(SEND_ERROR "Couldn't get version number for ${HT_SIGNTOOL}")
            message(SEND_ERROR "stdout: ${signtool_version_output}")
            message(SEND_ERROR "stderr: ${signtool_version_error}")
        endif()
    endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(HT_SIGNTOOL
    REQUIRED_VARS HT_SIGNTOOL HT_SIGNTOOL_VERSION
    VERSION_VAR HT_SIGNTOOL_VERSION
)

if(HT_SIGNTOOL AND NOT HT_SIGNTOOL_FOUND)
    set(HT_SIGNTOOL 0 CACHE STRING "" FORCE)
endif()
