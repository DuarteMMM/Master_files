################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Each subdirectory must supply rules for building sources it contributes
src/Vectors_intr.obj: ../src/Vectors_intr.asm $(GEN_OPTS) $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: C6000 Compiler'
	"D:/TI/ccsv6/tools/compiler/c6000_7.4.15/bin/cl6x" -mv6713 --abi=coffabi -g --include_path="D:/ti/ccsv6/ccs_base/C6000/csl6713/include" --include_path="D:/ti/ccsv6/ccs_base/C6000/dsk6713/include" --include_path="D:/TI/ccsv6/tools/compiler/c6000_7.4.15/include" --include_path="D:/workspace_v6_1/sine8_buf67/include" --define=CHIP_6713 --diag_warning=225 --diag_wrap=off --display_error_number --preproc_with_compile --preproc_dependency="src/Vectors_intr.pp" --obj_directory="src" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/c6713dskinit.obj: ../src/c6713dskinit.c $(GEN_OPTS) $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: C6000 Compiler'
	"D:/TI/ccsv6/tools/compiler/c6000_7.4.15/bin/cl6x" -mv6713 --abi=coffabi -g --include_path="D:/ti/ccsv6/ccs_base/C6000/csl6713/include" --include_path="D:/ti/ccsv6/ccs_base/C6000/dsk6713/include" --include_path="D:/TI/ccsv6/tools/compiler/c6000_7.4.15/include" --include_path="D:/workspace_v6_1/sine8_buf67/include" --define=CHIP_6713 --diag_warning=225 --diag_wrap=off --display_error_number --preproc_with_compile --preproc_dependency="src/c6713dskinit.pp" --obj_directory="src" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/sine8_buf.obj: ../src/sine8_buf.c $(GEN_OPTS) $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: C6000 Compiler'
	"D:/TI/ccsv6/tools/compiler/c6000_7.4.15/bin/cl6x" -mv6713 --abi=coffabi -g --include_path="D:/ti/ccsv6/ccs_base/C6000/csl6713/include" --include_path="D:/ti/ccsv6/ccs_base/C6000/dsk6713/include" --include_path="D:/TI/ccsv6/tools/compiler/c6000_7.4.15/include" --include_path="D:/workspace_v6_1/sine8_buf67/include" --define=CHIP_6713 --diag_warning=225 --diag_wrap=off --display_error_number --preproc_with_compile --preproc_dependency="src/sine8_buf.pp" --obj_directory="src" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '


