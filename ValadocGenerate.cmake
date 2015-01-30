##
# Copyright 2015 David Lechner <david@lechnology.com>
#
# Copied from: ValaPrecompile.cmake
# Copyright 2009-2010 Jakob Westhoff. All rights reserved.
# Copyright 2012 elementary.
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
#
# The views and conclusions contained in the software and documentation are those
# of the authors and should not be interpreted as representing official policies,
# either expressed or implied, of Jakob Westhoff
##

include(ParseArguments)
include (ValaVersion)
find_package(Valadoc REQUIRED)

##
# Generate Valadocs
#
# TARGET
#   The name of the CMake target. If not specified, it will be "valadoc".
#
# OUTPUT_DIRECTORY
#   The director to place the generated documentation in. If not specified, it
#   will be placed in ${CMAKE_CURRENT_BINARY_DIR}/valadoc
#
# PACKAGES
#   A list of vala packages/libraries to be used during the generation. The
#   package names are exactly the same, as they would be passed to the valadoc
#   "--pkg=" option.
#
# OPTIONS
#   A list of optional options to be passed to the valadoc executable.
#
# NO_PROTECTED
#   When set, protected elements will not be included.
#
# INTERNAL
#   When set, internal elements will be included.
#
# PRIVATE
#   When set, private elements will be included.
#
# The following call is a simple example to the generate_valadoc macro showing
# an example to every of the optional sections:
#
#   generate_valadoc(
#       source1.vala
#       source2.vala
#       source3.vala
#   TARGET
#       my-lib-valadoc
#   PACKAGE_NAME
#       my-lib
#   PACKAGE_VERSION
#       1.2.3
#   PACKAGES
#       gtk+-2.0
#       gio-1.0
#       posix
#   OPTIONS
#       --verbose
#   NO_PROTECTED
#   INTERNAL
#   PRIVATE
#   )
##

macro(generate_valadoc library_name)
    parse_arguments(ARGS
        "TARGET;PACKAGE_NAME;PACKAGE_VERSION;PACKAGES;OPTIONS"
        "NO_PROTECTED;INTERNAL;PRIVATE"
        ${ARGN}
    )

    if(NOT ARGS_TARGET)
        set(ARGS_TARGET valadoc)
    endif(NOT ARGS_TARGET)
    set(valadoc_clean_target "${ARGS_TARGET}-clean")
    if(NOT ARGS_OUTPUT_DIRECTORY)
        set(ARGS_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/valadoc)
    endif(NOT ARGS_OUTPUT_DIRECTORY)
    if(ARGS_PACKAGE_NAME)
        set(package_name_args "--package-name=${ARGS_PACKAGE_NAME}")
    endif(ARGS_PACKAGE_NAME)
    if(ARGS_PACKAGE_VERSION)
        set(package_version_args "--package-version=${ARGS_PACKAGE_VERSION}")
    endif(ARGS_PACKAGE_VERSION)
    set(valadoc_pkg_opts "")
    foreach(pkg ${ARGS_PACKAGES})
        list(APPEND vala_pkg_opts "--pkg=${pkg}")
    endforeach(pkg ${ARGS_PACKAGES})
    if(ARGS_NO_PROTECTED)
        set(${valadoc_no_protected_arg} "--no-protected")
    endif(ARGS_NO_PROTECTED)
    if(ARGS_INTERNAL)
        set(${valadoc_no_protected_arg} "--internal")
    endif(ARGS_INTERNAL)
    if(ARGS_PRIVATE)
        set(${valadoc_no_protected_arg} "--private")
    endif(ARGS_PRIVATE)

    add_custom_target(${ARGS_TARGET}
    COMMAND
        ${VALADOC_EXECUTABLE}
        "--driver=${VALA_VERSION}"
        "--directory=${ARGS_OUTPUT_DIRECTORY}"
        ${package_name_args}
        ${package_version_args}
        ${valadoc_pkg_opts}
        ${ARGS_OPTIONS}
        ${valadoc_no_protected_arg}
        ${valadoc_internal_arg}
        ${valadoc_private_arg}
        ${ARGS_DEFAULTS}
    DEPENDS
        ${valadoc_clean_target}
        ${ARGS_DEFAULTS}
    COMMENT
        "Generating valadoc in ${ARGS_OUTPUT_DIRECTORY}"
    )

    add_custom_target(${valadoc_clean_target}
        COMMAND
            rm -rf ${ARGS_OUTPUT_DIRECTORY}
        COMMENT
            "Removing generated valadoc directory ${ARGS_OUTPUT_DIRECTORY}"
    )

endmacro(generate_valadoc)
