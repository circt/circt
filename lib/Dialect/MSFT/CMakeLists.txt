##===- CMakeLists.txt - build definitions for MSFT ------------*- cmake -*-===//
##
## Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
## See https://llvm.org/LICENSE.txt for license information.
## SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
##
##===----------------------------------------------------------------------===//

file(GLOB globbed *.cpp)
add_circt_dialect_library(CIRCTMSFT
  ${globbed}

  ADDITIONAL_HEADER_DIRS
  ${CIRCT_MAIN_INCLUDE_DIR}/circt/Dialect/MSFT

  DEPENDS
  CIRCTHW
  MLIRMSFTIncGen
  MLIRMSFTExtraIncGen
  
  LINK_COMPONENTS
  Support

  LINK_LIBS PUBLIC
  MLIRIR
  MLIRTransforms
   )

add_dependencies(circt-headers MLIRMSFTIncGen)

add_subdirectory(TclExport)
