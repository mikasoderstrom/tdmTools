function d = matlabData(filename)
  data = csvread(filename);
  cvswrite('440kHz@16kHzReduced.cvs',data(40000:80000,:))
  
end