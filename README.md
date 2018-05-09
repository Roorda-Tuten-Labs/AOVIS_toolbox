# AOVIS_toolbox
MATLAB routines for analyzing AO vision experiments. These files were developed in the lab of Austin Roorda.

## Install

1. Open MATLAB as an administrator.

2. Change directory into AOVIS_toolbox:

```
cd AOVIS_toolbox
```

3. Run `install.m`. This will add AOVIS_toolbox and two dependencies onto your MATLAB path. 

The toolbox is now installed.

## Usage

Functions can be called following a dot notation, e.g. `delivery.add_delivery_error();`

## Contributions

The code contained in `+light_capture` was first developed by Will Tuten. Some of the functions in `+vid`, `+cone_select` and `+img` were provided by Ramkumar Sabesan. Wolf Harmening developed the original `vid.computetca` program, which has been lightly modified here for use with the current system in the Roorda lab. The UW toolbox was developed in the labs of Geoff Boynton and Ione Fine.
