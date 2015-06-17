NB. Api to read matlab files into J

require 'dll'

cocurrent 'matlab'

NB. == Host library path
NB.libmat=: IFUNIX{::'libmat.dll';('Darwin'-:UNAME){::'libmat.so';'libmat.dylib'
libmat=:'/Applications/MATLAB_R2015a.app/bin/maci64/libmat.dylib'
libmx=:'/Applications/MATLAB_R2015a.app/bin/maci64/libmx.dylib'
SZI=: IF64{4 8

NB. == MATFile functions
matOpen=: libmat, ' matOpen > x  *c *c'
matGetDir=: libmat, ' matGetDir > x  x x'
NB. mxArray* matGetNextVariableInfo(MATFile* pmat, char** nameptr)
matGetNextVariable=: libmat, ' matGetNextVariable > x  x x'
matClose=: libmat, ' matClose > i  x'  NB. int matClose(MATFile* pmat)

NB. == mxArray functions
mxGetNumberOfDimensions=: libmx, ' mxGetNumberOfDimensions_730 > i  x'
mxIsDouble=: libmx, ' mxIsDouble > i x'
mxGetDimensions=: libmx, ' mxGetDimensions_730 > x  x'
mxGetNumberOfElements=: libmx, ' mxGetNumberOfElements > i  x'
mxGetPr=: libmx, ' mxGetPr > x  x'  NB.  double* mxGetPr(mxArray *pa)
mxGetData=: libmx, ' mxGetData > x  x'  NB.  void* mxGetData(mxArray *pa)  
mxGetClassID=: libmx, ' mxGetClassID > i  x'
mxGetImagData=: libmx, ' mxGetImagData  > x  x'  

NB. adverb to make a verb that throws error 11 (nonce) with error message
notImp=: 1 : '(13!:8)@:(11"_)@:smoutput@:(m"_)'

NB. Binary to J conversion verbs 
unknown=. 'Mat type is unkown' notImp
int1=: 'Signed 1 byte integer not implemented yet' notImp
uint1=: a.&i.
int2=: _1 & ic  
uint2=: 0 & ic  
int4=: _2 & ic  
uint4=: 'Unsigned 4 byte integer not implemented yet' notImp
int8=: _3 & ic  
uint8=: 'Unsigned 8 byte integer not implemented yet' notImp
float4=: _1 & fc 
float8=: _2 & fc
int2j=: (-2+IF64) & ic   NB. 4 or 8 byte binary integer to J

NB. mxClassID  numbytes  binary_converter
mxTypes=: dltb each ('|'&cut;._2) 0 : 0
mxUNKNOWN_CLASS  | 0 |  unknown
mxCELL_CLASS     | 0 | 'Reading mxCELL not implemented'notImp
mxSTRUCT_CLASS   | 0 | 'Reading mxSTRUCT not implemented'notImp
mxLOGICAL_CLASS  | 1 |  uint1
mxCHAR_CLASS     | 1 | 'Reading mxCHAR not implemented'notImp
mxVOID_CLASS     | 0 | 'Reading mxVOID not implemented'notImp
mxDOUBLE_CLASS   | 8 |  float8 
mxSINGLE_CLASS   | 4 |  float4
mxINT8_CLASS     | 1 | 'Reading mxINT8 not implemented'notImp
mxUINT8_CLASS    | 1 |  uint1
mxINT16_CLASS    | 2 |  int2
mxUINT16_CLASS   | 2 |  uint2
mxINT32_CLASS    | 4 |  int4
mxUINT32_CLASS   | 4 |  uint4
mxINT64_CLASS    | 8 |  int8
mxUINT64_CLASS   | 8 |  uint8
mxFUNCTION_CLASS | 0 | 'Reading mxFUNCTION not implemented'notImp
mxOPAQUE_CLASS   | 0 | 'Reading mxOPAQUE not implemented'notImp
mxOBJECT_CLASS   | 0 | 'Reading mxOBJECT not implemented'notImp
)

readmat=: monad define
  filename=.y
  (filename, ' does not exist.') assert fexist filename

  0$stdout 'Load ''', filename, '''... '
  pmat=. matOpen cd filename;1$'r'  NB. MATFile*
  smoutput 'done'

  NB. List variables (TODO: doesn't work)
  NB.pndir=: mema SZI
  NB.ppdirs=: matGetDir cd pmat;pndir

  stdout 'Read first mxArray... '
  ppname=. mema SZI  
  pa=. matGetNextVariable cd pmat;ppname  NB. mxArray*
  NB.echo 'done'
  smoutput 'done'

  smoutput 'Get mxArray info'
  name=. memr (memr ppname,0,1,4),0,_1,2
  ndims=. mxGetNumberOfDimensions cd pa
  pdims=. mxGetDimensions cd pa
  dims=. memr pdims,0,ndims,4
  isDouble=. mxIsDouble cd pa
  classID=. mxGetClassID cd pa
  mxType=. (<classID,0) {:: mxTypes
  numBytes=. ". (<classID,1) {:: mxTypes 
  smoutput (,: ".each)@;:'name dims classID mxType isDouble numBytes'

  stdout 'Read the array data ...'
  if. isDouble do.
    pdata=. mxGetPr cd pa
  else.
    pdata=. mxGetData cd pa
  end.
  data=. memr pdata, 0, numBytes * (*/ dims)
  ". 'binary_converter=: ', (<classID,2) {:: mxTypes
  output=. (|.dims) $ (binary_converter) data
  smoutput 'done'

  stdout 'Close the file ...'
  matClose cd pmat
  smoutput 'done'

  output
)

readmat_z_=: readmat_matlab_
