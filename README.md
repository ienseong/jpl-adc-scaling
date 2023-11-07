# jpl-adc-scaling

## Overview
<img src="https://github-fn.jpl.nasa.gov/storage/user/1098/files/73b69370-3a1c-4e05-a0c9-d4dc3a0a0865"  width="400" height="300"/>
This module processes the output from an ADC: running a calibration sequence to determine an offset, subtracting out the offset from subsequent values, and scaling the result according to the following equations:

`o_result = ((i_adc_raw - offset) * i_scale_val) / (2^D)`

The offset can be computed during calibration or supplied externally:

`offset = (i_offset_mode) ? i_ext_offset : cal_offset`

The calibration offset is calculated during calibration as follows:

`cal_offset = (Sum of AVG samples of i_adc_raw)>>LOG2AVG`

## Documentation

For details of the module, see the [specification](https://github-fn.jpl.nasa.gov/jpl-fpga-ip-incubator-fn/jpl_adc-scaling/blob/master/docs/FPGA_DesignSpec_ADC_Scaling.doc).

## Unit Test

For instructions on how to run the unit test, see the [README](https://github-fn.jpl.nasa.gov/jpl-fpga-ip-incubator/jpl-adc-scaling/blob/main/verif/README.md).
