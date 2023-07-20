################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Each subdirectory must supply rules for building sources it contributes
aic3204_test.obj: ../aic3204_test.c $(GEN_OPTS) $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: C5500 Compiler'
	"D:/TI/ccsv6/tools/compiler/c5500_4.4.1/bin/cl55" -vcpu:3.3 --memory_model=large -g --include_path="D:/TI/ccsv6/tools/compiler/c5500_4.4.1/include" --include_path="D:/ti/ccsv6/ccs_base/usbstk5515_BSL_RevA/usbstk5515_v1/include" --diag_warning=225 --ptrdiff_size=32 --preproc_with_compile --preproc_dependency="aic3204_test.pp" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

main.obj: ../main.c $(GEN_OPTS) $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: C5500 Compiler'
	"D:/TI/ccsv6/tools/compiler/c5500_4.4.1/bin/cl55" -vcpu:3.3 --memory_model=large -g --include_path="D:/TI/ccsv6/tools/compiler/c5500_4.4.1/include" --include_path="D:/ti/ccsv6/ccs_base/usbstk5515_BSL_RevA/usbstk5515_v1/include" --diag_warning=225 --ptrdiff_size=32 --preproc_with_compile --preproc_dependency="main.pp" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '


