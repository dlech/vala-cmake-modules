################################################################################
# FindGirCompiler.cmake
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

find_program(G_IR_COMPILER_EXE NAMES g-ir-compiler)
mark_as_advanced (G_IR_COMPILER_EXE)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GirCompiler DEFAULT_MSG G_IR_COMPILER_EXE)

#
# add_typelib: CMake wrapper around g-ir-compiler to create .typelib files
#
# TARGET
#   The name of the cmake target. The TYPELIB_FILE property of this target
#   will be set to the name of the generated file.
#
# GIR_TARGET
#   The name of a target with the GIR_FILE property set to the full path
#   of a .gir file.
#
# ARGS
#   Additional arguments to pass directly to g-ir-compiler
#
function(add_typelib TARGET GIR_TARGET)
    cmake_parse_arguments(ARGS "" "" "ARGS" ${ARGN})

    get_target_property(GIR_FILE ${GIR_TARGET} GIR_FILE)
    string(REPLACE ".gir" ".typelib" TYPELIB_FILE ${GIR_FILE})

    add_custom_command(OUTPUT ${TYPELIB_FILE}
        COMMAND ${G_IR_COMPILER_EXE}
        ARGS
            --output=${TYPELIB_FILE}
            ${ARGS_ARGS}
            ${GIR_FILE}
        DEPENDS
            ${GIR_TARGET}
            ${GIR_FILE}
    )

    add_custom_target(${TARGET} ALL DEPENDS ${TYPELIB_FILE})
    set_property(TARGET ${TARGET} PROPERTY TYPELIB_FILE
        ${CMAKE_CURRNET_BINARY_DIR}/${TYPELIB_FILE})
endfunction()

#
# Installs a typelib given by TARGET
#
# Usage:
#   install_typelib(<target> DESTINATION <destination>)
#
# <target> is any target with the TYPELIB_FILE property set to the path of a .typelib file
# <destination> is the system data directory, e.g. CMAKE_INSTALL_LIBDIR
#
function(install_typelib TARGET)
    cmake_parse_arguments(ARGS "" "DESTINATION" "" ${ARGN})
    if(APPLE)
        # have to regenerate .typelib file to get the shared library name correct
        # TODO: find a less fragile way to get girDir or perhaps use the --shared-library argument to g-ir-compiler
        set(girDir "\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/share/gir-1.0")
        set(girFile "${girDir}/${GIR_NAME}-${GIR_VERSION}.gir")
        set(typelibDir "\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${ARGS_DESTINATION}/girepository-1.0")
        set(typelibFile "${typelibDir}/${GIR_NAME}-${GIR_VERSION}.typelib")
        install(CODE "message(\"-- Installing: ${typelibFile}\")\n  file(MAKE_DIRECTORY \"${typelibDir}\")\n  execute_process(COMMAND ${G_IR_COMPILER_EXE} \"--output=${typelibFile}\" \"${girFile}\")")
    else (APPLE)
        install(FILES $<TARGET_PROPERTY:${TARGET},TYPELIB_FILE> DESTINATION ${ARGS_DESTINATION}/girepository-1.0)
    endif(APPLE)
endfunction()
