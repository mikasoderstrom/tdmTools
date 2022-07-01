function d = tdmplayer(filename, mic)
  data = csvread(filename);

  fs = data(1, 1);

  micdata = 0.00001*data(60000:80000, mic);
  
  figure(17)
  clf;
  V = fft(micdata);
  f = fs*(0:length(V)/2-1)/length(V);
  plot(f, abs(V(1:floor(length(V)/2))))

  [B, A] = butter (3, 2*100/fs, 'high');

  ## filteredmicdata = filter(B, A, micdata);
  filteredmicdata = filtfilt(B, A, micdata);
  player = audioplayer(micdata, fs)
  play(player);
  pause;
  figure(18)
  clf;
  hold on;
  plot(micdata, 'b');
  plot(filteredmicdata, 'r');

