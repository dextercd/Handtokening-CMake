find_program(HT_SIGNTOOL_EXECUTABLE signtool.exe)

if(HT_SIGNTOOL_EXECUTABLE)
    cmake_path(NATIVE_PATH HT_SIGNTOOL_EXECUTABLE COMMAND_PATH)

    execute_process(
        COMMAND
            ${CMAKE_COMMAND} -E env "E=${HT_SIGNTOOL_EXECUTABLE}"
            powershell.exe -NoProfile -Command "(Get-Item $env:E).VersionInfo.ProductVersion"
        OUTPUT_VARIABLE signtool_version_output
        ERROR_VARIABLE signtool_version_error
        RESULT_VARIABLE signtool_version_result
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT signtool_version_result EQUAL 0)
        message(SEND_ERROR "get version command failed.")
        message(SEND_ERROR "stdout: ${signtool_version_output}")
        message(SEND_ERROR "stderr: ${signtool_version_error}")
    else()
        if(signtool_version_output MATCHES "([0-9]+[.][0-9]+[.][0-9]+[.][0-9]+)")
            set(HT_SIGNTOOL_VERSION "${CMAKE_MATCH_1}")
            message("FOUND VERSION ${HT_SIGNTOOL_VERSION}")
        else()
            message(SEND_ERROR "Couldn't get version number for ${HT_SIGNTOOL_EXECUTABLE}")
            message(SEND_ERROR "stdout: ${signtool_version_output}")
            message(SEND_ERROR "stderr: ${signtool_version_error}")
        endif()
    endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(HT_SIGNTOOL
    REQUIRED_VARS HT_SIGNTOOL_EXECUTABLE HT_SIGNTOOL_VERSION
    VERSION_VAR HT_SIGNTOOL_VERSION
)

if (HT_SIGNTOOL_FOUND)
    set(HT_SIGNTOOL "${HT_SIGNTOOL_EXECUTABLE}")
endif()
