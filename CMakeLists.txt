cmake_minimum_required(VERSION 3.21)

project(Handtokening_CMake
    DESCRIPTION "Project for connecting a CMake build to a Handtokening server"
    HOMEPAGE_URL "https://github.com/dextercd/Handtokening-CMake"
    LANGUAGES
)

if(HT_SETUP_DONE)
    return()
endif()

set(HT_SETUP_DONE TRUE PARENT_SCOPE)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake PARENT_SCOPE)
