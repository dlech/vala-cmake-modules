################################################################################
# FindGirScanner.cmake
################################################################################

# MIT License
#
# Copyright (c) 2018 David Lechner <david@lechnology.com>
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

find_program(G_IR_SCANNER_EXE NAMES g-ir-scanner)
mark_as_advanced(G_IR_SCANNER_EXE)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GirCompiler DEFAULT_MSG G_IR_SCANNER_EXE)

#
# add_gir: CMake wrapper around g-ir-scanner to create .gir files
#
# TARGET
#   Variable to store the name of the cmake target. The GIR_FILE property
#   of this target will be set to the name of the generated file.
#
# SHARED_LIBRARY_TARGET
#   The shared library target that this gir will be generated from.
#
# NAMESPACE
#   Namespace used in the generated file.
#
# VERSION
#   Namespace version used in the generated file.
#
# INCLUDES
#   List of other Girs that this depends on.
#
# INCLUDE_DIRS
#   List of directories in which to search for header files.
#
# ARGS
#   Additional arguments to pass directly to g-ir-scanner
#
# FILES
#   List of files to be scanned.
#
# The following call is a simple example to the add_gir macro showing
# an example to every of the optional sections:
#
#   add_gir (MY_GIR ${MY_LIBRARY} MyGir 1.0
#       INCLUDES
#           GLib-2.0
#       INCLUDE_DIRS
#           /usr/include/glib-2.0/
#       ARGS
#           --warn-error
#       FILES
#           my_gir.h
#           my_gir.c
#   )
#
function(add_gir TARGET SHARED_LIBRARY_TARGET NAMESPACE VERSION)
    cmake_parse_arguments(ARGS "" "" "INCLUDES;INCLUDE_DIRS;ARGS;FILES" ${ARGN})

    set(GIR_FILE ${NAMESPACE}-${VERSION}.gir)

    set(INCLUDES "")
    foreach(PKG ${ARGS_INCLUDES})
        list(APPEND INCLUDES "--include=${PKG}")
    endforeach()

    set(INCLUDE_DIRS "")
    foreach(DIR ${ARGS_INCLUDE_DIRS})
        list(APPEND INCLUDE_DIRS "-I${DIR}")
    endforeach()

    set(FILES "")
    foreach (FILE ${ARGS_FILES})
        get_filename_component(ABS_FILE ${FILE} ABSOLUTE)
        list(APPEND FILES "${ABS_FILE}")
    endforeach()

    add_custom_command(OUTPUT ${GIR_FILE}
        COMMAND ${G_IR_SCANNER_EXE}
        ARGS
            ${INCLUDES}
            --verbose
            --library=$<TARGET_PROPERTY:${SHARED_LIBRARY_TARGET},OUTPUT_NAME>
            --library-path=$<TARGET_SONAME_FILE_DIR:${SHARED_LIBRARY_TARGET}>
            --namespace=${NAMESPACE}
            --nsversion=${VERSION}
            --no-libtool
            --output=${GIR_FILE}
            ${INCLUDE_DIRS}
            ${ARGS_ARGS}
            ${FILES}
        DEPENDS
            ${SHARED_LIBRARY_TARGET}
            ${FILES}
    )

    add_custom_target(${TARGET} ALL DEPENDS ${GIR_FILE})
    set_target_properties(${TARGET}
        PROPERTIES
            GIR_NAMESPACE ${NAMESPACE}
            GIR_VERSION ${VERSION}
            GIR_FILE ${CMAKE_CURRENT_BINARY_DIR}/${GIR_FILE}
    )

    set(${TARGET} ${TARGET})
endfunction()

#
# Installs a .gir file from TARGET to DESTINATION
#
# Usage:
#   install_gir(<target> DESTINATION <destination>)
#
# <target> is any target with the GIR_FILE property set to the path of a .gir file
# <destination> is the system data directory, e.g. CMAKE_INSTALL_DATAROOTDIR
#
function(install_gir TARGET)
    cmake_parse_arguments(ARGS "" "DESTINATION" "" ${ARGN})

    install(FILES $<TARGET_PROPERTY:${TARGET},GIR_FILE> DESTINATION ${ARGS_DESTINATION}/gir-1.0/)
    if (APPLE)
        # need to fix shared library name - this is the equivalent of install_name_tool for .gir files
        # TODO: find a less fragile way to get the shared library path instead of ${CMAKE_INSTALL_PREFIX}/lib
        install (CODE "execute_process(COMMAND sed -e \"s`\\\\(shared-library=\\\"\\\\).*/\\\\(.*\\\"\\\\)`\\\\1${CMAKE_INSTALL_PREFIX}/lib/\\\\2`\" -i \\\"\\\" \"\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${ARGS_DESTINATION}/gir-1.0/${GIR_NAME}-${GIR_VERSION}.gir\")")
    endif (APPLE)
endfunction()
