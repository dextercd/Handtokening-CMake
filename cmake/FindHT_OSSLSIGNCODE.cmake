find_program(HT_OSSLSIGNCODE_EXECUTABLE osslsigncode)

if(HT_OSSLSIGNCODE_EXECUTABLE)
    execute_process(COMMAND ${HT_OSSLSIGNCODE_EXECUTABLE} --version
        OUTPUT_VARIABLE osslsigncode_version_output
        ERROR_VARIABLE osslsigncode_version_error
        RESULT_VARIABLE osslsigncode_version_result
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT osslsigncode_version_result EQUAL 0)
        message(SEND_ERROR "Command failed: ${HT_OSSLSIGNCODE_EXECUTABLE} --version:\n${osslsigncode_version_error}")
    else()
        if(osslsigncode_version_output MATCHES "^osslsigncode ([0-9]+[.][0-9]+([.][0-9]+)?)")
            set(HT_OSSLSIGNCODE_VERSION "${CMAKE_MATCH_1}")
        else()
            message(SEND_ERROR "Couldn't get version number from ${HT_OSSLSIGNCODE_EXECUTABLE} --version:\n${osslsigncode_version_output}")
        endif()
    endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(HT_OSSLSIGNCODE
    REQUIRED_VARS HT_OSSLSIGNCODE_EXECUTABLE HT_OSSLSIGNCODE_VERSION
    VERSION_VAR HT_OSSLSIGNCODE_VERSION
)

if(HT_OSSLSIGNCODE_FOUND)
    set(HT_OSSLSIGNCODE "${HT_OSSLSIGNCODE_EXECUTABLE}")
endif()
