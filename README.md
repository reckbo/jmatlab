J interface to read MATLAB files.  Right now it only reads in the first variable.
The following types are supported:

* logical
* double 
* single 
* 8 bit int - unsigned
* 16 bit int
* 16 bit int - unsigned
* 32 bit int 
* 64 bit int

I've only tested this using a 64 bit Mac.  The shared library paths are
hardcoded so if you want to try it on Linux or Windows change the values of
`libmat` and `libmx` in `matlab.ijs` first.
