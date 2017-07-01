################################################################################
# FindValac.cmake
################################################################################

# MIT License
#
# Copyright (c) 2017 David Lechner <david@lechnology.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

find_program(VALAC_EXE NAMES valac)
mark_as_advanced(VALAC_EXE)
include (FindPackageHandleStandardArgs)
find_package_handle_standard_args(Valac DEFAULT_MSG VALAC_EXE)

#
# vala2c - compile Vala source files into C source files
#
# Usage:
#
# vala2c(<target> SOURCE_FILES <file1> [<file2> ...]
#   [PACKAGES <pkg1> [<pkg2> ...]]
#   [TARGET_GLIB <major>.<minor>]
#   [OUTPUT_DIR <dir>]
# )
#
# <target> is a variable to hold a list of generated C files.
# SOURCE_FILES is a list of the source (.vala) files.
# PACKAGES is a list of vala package dependencies (e.g. glib-2.0).
# TARGET_GLIB is the target glib version.
# OUTPUT_DIR is the location where the generated files will be written. The
#   default is ${CMAKE_CURRENT_BINARY_DIR}
#
# The generated C files can then be used with add_library() or add_executable()
# to generate the usual CMake targets.
#
function(vala2c TARGET)
    set(optionArgs "")
    set(oneValueArgs VAPI LIBRARY SHARED_LIBRARY OUTPUT_DIR TARGET_GLIB)
    set(multiValueArgs SOURCE_FILES VAPI_DIRS GIR_DIRS METADATA_DIRS PACKAGES)
    cmake_parse_arguments(VALA2C "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # determine the output directory
    set(outputDir "${CMAKE_CURRENT_BINARY_DIR}")
    if(VALA2C_OUTPUT_DIR)
        if(IS_ABSOLUTE "${VALA2C_OUTPUT_DIR}")
            set(outputDir "${VALA2C_OUTPUT_DIR}")
        else()
            set(outputDir "${outputDir}/${VALA2C_OUTPUT_DIR}")
        endif()
    endif()

    # make a list of generated c files
    if(VALA2C_SOURCE_FILES)
        foreach(sourceFile ${VALA2C_SOURCE_FILES})
            get_filename_component(cFile "${sourceFile}" NAME_WE)
            set(cFile "${outputDir}/${cFile}.c")
            list(APPEND outputFiles "${cFile}")
        endforeach()
    else()
        message(FATAL_ERROR "Missing SOURCE_FILES argument for vala2c")
    endif()

    # optional PACKAGES argument
    if(VALA2C_PACKAGES)
        foreach(package ${VALA2C_PACKAGES})
            list(APPEND pkgArgs "--pkg=${package}")
        endforeach()
    endif()

    # optional TARGET_GLIB arguemtn
    if(VALA2C_TARGET_GLIB)
        set(targetGLibArg "--target-glib=${VALA2C_TARGET_GLIB}")
    endif()

    add_custom_command(OUTPUT ${outputFiles}
        COMMAND "${VALAC_EXE}"
            ${pkgArgs}
            --directory="${outputDir}"
            --ccode
            ${targetGLibArg}
            ${VALA2C_SOURCE_FILES}
        WORKING_DIRECTORY
            ${CMAKE_CURRENT_SOURCE_DIR}
        DEPENDS
            ${VALA2C_SOURCE_FILES}
    )

    set(${TARGET} ${outputFiles} PARENT_SCOPE)

endfunction()