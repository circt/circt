add_circt_conversion_library(CIRCTLLHDToLLVM
  LLHDToLLVM.cpp

  DEPENDS
  CIRCTConversionPassIncGen

  LINK_COMPONENTS
  Core

  LINK_LIBS PUBLIC
  CIRCTLLHD
  MLIRLLVMIR
  MLIRStandardToLLVM
  MLIRVector
  MLIRTransforms
)
