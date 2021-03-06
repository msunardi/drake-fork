# Macros to simplify compliance with the pods build policies.
#
# To enable the macros, add the following line to CMakeLists.txt:
#   include(cmake/pods.cmake)
#
# Next, any of the following macros can be used.  See the individual macro
# definitions in this file for individual documentation.
#
# General
#   pods_config_search_paths()
#
# ----
# File: pods.cmake
# Distributed with pods version: 12.11.14

# pods_config_search_paths()
#
# Setup rpath and install name path according to the pods core policy. This
# macro is automatically invoked, there is no need to do so manually.
macro(pods_config_search_paths)
    if(NOT DEFINED __pods_setup)
      # abuse RPATH
      if(CMAKE_INSTALL_RPATH)
        set(CMAKE_INSTALL_RPATH ${DRAKE_LIBRARY_DIR}:${CMAKE_INSTALL_RPATH})
      else()
        set(CMAKE_INSTALL_RPATH ${DRAKE_LIBRARY_DIR})
      endif()

      # for OS X, which uses "install name" path rather than rpath
      set(CMAKE_INSTALL_NAME_DIR ${CMAKE_INSTALL_RPATH})

      set(__pods_setup TRUE)
    endif()
endmacro()

pods_config_search_paths()
