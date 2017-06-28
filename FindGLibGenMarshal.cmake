##
# Copyright 2017 David Lechner. All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
#    1. Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
# 
#    2. Redistributions in binary form must reproduce the above copyright notice,
#       this list of conditions and the following disclaimer in the documentation
#       and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY JAKOB WESTHOFF ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL JAKOB WESTHOFF OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##

find_program (GLIB_GENMARSHAL_EXE NAMES glib-genmarshal)
mark_as_advanced (GLIB_GENMARSHAL_EXE)

include (FindPackageHandleStandardArgs)
find_package_handle_standard_args (GLibGenMarshal DEFAULT_MSG GLIB_GENMARSHAL_EXE)

include (CMakeParseArguments)

#
# Usage:
#
# glib_genmarshal (HEADER_FILE <file.h> CODE_FILE <file.c>
#   [INTERNAL] [WARNINGS_FATAL] [VALIST] [PREFIX <prefix>] [STANDARD_INCLUDE <yes/no>]
#   LIST_FILES <file1> [<file2> [...]])
#
function (glib_genmarshal)
    set (_option_args "INTERNAL" "WARNINGS_FATAL" "VALIST")
    set (_one_value_args "HEADER_FILE" "CODE_FILE" "PREFIX" "STANDARD_INCLUDE")
    set (_multi_value_args "LIST_FILES")
    cmake_parse_arguments ("GLIB_GENMARSHAL" "${_option_args}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

    if (GLIB_GENMARSHAL_HEADER_FILE)
        if (NOT IS_ABSOLUTE "${GLIB_GENMARSHAL_HEADER_FILE}")
            set (GLIB_GENMARSHAL_HEADER_FILE "${CMAKE_CURRENT_BINARY_DIR}/${GLIB_GENMARSHAL_HEADER_FILE}")
        endif (NOT IS_ABSOLUTE "${GLIB_GENMARSHAL_HEADER_FILE}")
        get_filename_component (GLIB_GENMARSHAL_HEADER_DIR "${GLIB_GENMARSHAL_HEADER_FILE}" DIRECTORY)
    else (GLIB_GENMARSHAL_HEADER_FILE)
        message (FATAL_ERROR "Missing HEADER_FILE argument")
    endif (GLIB_GENMARSHAL_HEADER_FILE)

    if (GLIB_GENMARSHAL_CODE_FILE)
        if (NOT IS_ABSOLUTE "${GLIB_GENMARSHAL_CODE_FILE}")
            set (GLIB_GENMARSHAL_CODE_FILE "${CMAKE_CURRENT_BINARY_DIR}/${GLIB_GENMARSHAL_CODE_FILE}")
        endif (NOT IS_ABSOLUTE "${GLIB_GENMARSHAL_CODE_FILE}")
        get_filename_component (GLIB_GENMARSHAL_CODE_DIR "${GLIB_GENMARSHAL_CODE_FILE}" DIRECTORY)
    else (GLIB_GENMARSHAL_CODE_FILE)
        message (FATAL_ERROR "Missing CODE_FILE argument")
    endif (GLIB_GENMARSHAL_CODE_FILE)

    if (GLIB_GENMARSHAL_LIST_FILES)
        foreach (_file ${GLIB_GENMARSHAL_LIST_FILES})
            if (NOT IS_ABSOLUTE "${_file}")
                set (_file "${CMAKE_CURRENT_SOURCE_DIR}/${_file}")
            endif (NOT IS_ABSOLUTE "${_file}")
            list (APPEND _list_files "${_file}")
        endforeach (_file GLIB_GENMARSHAL_LIST_FILES)
        
    else (GLIB_GENMARSHAL_LIST_FILES)
        message (FATAL_ERROR "Missing LIST_FILES argument")
    endif (GLIB_GENMARSHAL_LIST_FILES)

    if (GLIB_GENMARSHAL_PREFIX)
        set (_prefix_arg "--prefix=${GLIB_GENMARSHAL_PREFIX}")
    endif (GLIB_GENMARSHAL_PREFIX)

    if (GLIB_GENMARSHAL_INTERNAL)
        set (_internal_arg "--internal")
    endif (GLIB_GENMARSHAL_INTERNAL)
    
    if (GLIB_GENMARSHAL_WARNINGS_FATAL)
        set (_warnings_fatal_arg "--g-fatal-warnings")
    endif (GLIB_GENMARSHAL_WARNINGS_FATAL)

    if (GLIB_GENMARSHAL_WARNINGS_VALIST)
        set (_valist_arg "--valist-marshallers")
    endif (GLIB_GENMARSHAL_WARNINGS_VALIST)

    if (GLIB_GENMARSHAL_STANDARD_INCLUDE)
        if (${GLIB_GENMARSHAL_STANDARD_INCLUDE})
            set (_stdinc_arg "--stdinc")
        else (${GLIB_GENMARSHAL_STANDARD_INCLUDE})
            set (_stdinc_arg "--nostdinc")
        endif (${GLIB_GENMARSHAL_STANDARD_INCLUDE})
    endif (GLIB_GENMARSHAL_STANDARD_INCLUDE)

    add_custom_command (OUTPUT ${GLIB_GENMARSHAL_HEADER_FILE}
        COMMAND ${CMAKE_COMMAND} -E make_directory
            ${GLIB_GENMARSHAL_HEADER_DIR}
        COMMAND ${GLIB_GENMARSHAL_EXE}
            --header
            ${_prefix_arg}
            ${_internal_arg}
            ${_warnings_fatal_arg}
            ${_stdinc_arg}
            ${_valist_arg}
            ${_list_files}
            > ${GLIB_GENMARSHAL_HEADER_FILE}
        DEPENDS ${_list_files}
    )

    add_custom_command (OUTPUT ${GLIB_GENMARSHAL_CODE_FILE}
        COMMAND ${CMAKE_COMMAND} -E make_directory
            ${GLIB_GENMARSHAL_CODE_DIR}
        COMMAND ${GLIB_GENMARSHAL_EXE}
            --body
            ${_prefix_arg}
            ${_internal_arg}
            ${_warnings_fatal_arg}
            ${_stdinc_arg}
            ${_valist_arg}
            ${_list_files}
            > ${GLIB_GENMARSHAL_CODE_FILE}
        DEPENDS ${_list_files}
    )

endfunction (glib_genmarshal)
