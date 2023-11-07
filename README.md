# jpl-adc-scaling

## Overview

![image](https://github.jpl.nasa.gov/storage/user/1047/files/81acba00-b367-4d26-82eb-d4e59f116d2e)


This module processes the output from an ADC: running a calibration sequence to determine an offset, subtracting out the offset from subsequent values, and scaling the result according to the following equations:

`o_result = ((i_adc_raw - offset) * i_scale_val) / (2^D)`

The offset can be computed during calibration or supplied externally:

`offset = (i_offset_mode) ? i_ext_offset : cal_offset`

The calibration offset is calculated during calibration as follows:

`cal_offset = (Sum of AVG samples of i_adc_raw)>>LOG2AVG`

## Documentation

For details of the module, see the [specification](https://github.jpl.nasa.gov/jpl-fpga-ip-incubator/jpl-adc-scaling/blob/main/docs/FPGA_DesignSpec_ADC_Scaling.doc).

## Unit Test

For instructions on how to run the unit test, see the [README](https://github.jpl.nasa.gov/jpl-fpga-ip-incubator/jpl-adc-scaling/blob/main/verif/README.md).
