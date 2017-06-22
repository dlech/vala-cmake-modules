##
# Copyright 2017 David Lechner <david@lechnology.com>
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

find_program (G_IR_DOC_TOOL_EXE NAMES g-ir-doc-tool)
mark_as_advanced (G_IR_DOC_TOOL_EXE)

include (FindPackageHandleStandardArgs)
find_package_handle_standard_args (GirDocTool DEFAULT_MSG G_IR_DOC_TOOL_EXE)

include (CMakeParseArguments)

#
# Usage:
#
# add_gir_doc (<target-name> <python|gjs|c> GIR_FILE <file.gir> DESTINATION <directory>)
#
function (add_gir_doc TARGET LANGUAGE)
    set (_one_value_args "GIR_FILE" "DESTINATION")
    cmake_parse_arguments (GIR_DOC "" "${_one_value_args}" "" "${ARGN}")

    if (NOT GIR_DOC_GIR_FILE)
        message (FATAL_ERROR "Missing GIR_FILE argument")
    endif ()

    if (NOT GIR_DOC_DESTINATION)
        message (FATAL_ERROR "Missing DESTINATION argument")
    endif ()

    add_custom_command (OUTPUT ${TARGET}.stamp
        COMMAND ${G_IR_DOC_TOOL_EXE}
            --output ${GIR_DOC_DESTINATION}
            --language ${LANGUAGE}
            ${GIR_DOC_GIR_FILE}
        COMMAND
            ${CMAKE_COMMAND} -E touch ${TARGET}.stamp
        DEPENDS
            ${GIR_DOC_GIR_FILE}
    )

    add_custom_target (${TARGET} DEPENDS ${TARGET}.stamp)

endfunction ()
