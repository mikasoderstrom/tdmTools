function d = pcmeval2()
  ## plot options
  fig1 = 0;
  fig2 = 0;
  fig3 = 0;
  fig4 = 0;
  fig5 = 0;
  fig6 = 1;
  fig7 = 1;
  fig8 = 1;
  allFigs = 1;

  fig = [fig1 fig2 fig3 fig4 fig5 fig6 fig7 fig8];

  ## Delete mic data
  delete = 1;                       % if true, deletes data from a mic
  micToDelete = [1 17 30 33 49 64];         % mics to delete

  ## Scale mic data
  scale = 0;
  micToScale = 30;

  ## Write all ok values to file
  write = 0;

  ## Read mic data from file
  %filename = '440kHz@16kHz';
  filename = '880@16kHz_PCBA1';
  path = strcat('~/src/ljudkriget/', filename, '.bin.txt');
  data = csvread(path);


  fs = data(1, 1) ## sample frequency
  f0 = str2num(filename(1:3)) ## sound frequency in Hz


  accumInit = [];
  accumOkValues = [];
  allOkValues = [];
  accumAllValues = [];

  allValues = data(:,3:66);
  
  for i = 3:66
    values = data(:, i); ## Values from mic i
    #allValues = values(:);
    #accumAllValues = [accumAllValues allValues];

    ## initial values
    initValues = values(10:4000);
    initLen = length(initValues);
    accumInit = [accumInit initValues];

    ## ok values
    okValues = values(40000:80000);
    accumOkValues = [accumOkValues okValues(1:60)];
    allOkValues = [allOkValues okValues(1:length(okValues))];

  end

  [allValues allOkValues accumOkValues accumInit] = deleteMic(delete, micToDelete, allValues, allOkValues, accumOkValues, accumInit);

  writeToFile(write, filename, allOkValues)

  plots(fig, allFigs, allValues, allOkValues, accumOkValues, accumInit, fs, f0)

  audiowrite('29062022.wav' , data(20000:end, 8)/100000, fs, 'BitsPerSample', 24);

  #allOkValues = scaleMic(scale, allOkValues, micToScale);
  #plots(fig1, fig2, fig3, fig4, allFigs, allOkValues, accumOkValues, accumInit)

end

function [allValues allOkValues accumOkValues accumInit] = deleteMic(delete, micToDelete, allValues, allOkValues, accumOkValues, accumInit)
  if (delete)
    for i=1:length(micToDelete)
      allValues(:,micToDelete(i)) = 0;
      allOkValues(:,micToDelete(i)) = 0;
      accumOkValues(:,micToDelete(i)) = 0;
      accumInit(:,micToDelete(i)) = 0;
    end
  endif
endfunction

function plots(fig, allFigs, allValues, allOkValues, accumOkValues, accumInit, fs, f0)
  if (fig(1)||allFigs)
    figure(1)
    clf;
    plot(accumOkValues)
    zoom on
  endif

  if (fig(2)||allFigs)
    figure(2)
    clf
    hold on
    zoom on
    for j = 1:4
      for i = 1:16
        plot ((i-1)*60+[1:60], accumOkValues(:, i+(j-1)*16)+(j-1)*100000, '-*')
      end
    end
  endif

  if (fig(3)||allFigs)
    figure(3);
    clf;
    ## plot(f, abs(V(1:floor(length(V)/2))));
    plot(accumInit)
    zoom on
  endif

  if (fig(4)||allFigs)
    figure(4);
    clf;
    hold on;
    zoom on
    for i = 1:64
      # plot ((i-1)*initLen+[1:initLen], accumInit(:, i))
      plot ((i-1)*rows(accumInit)+[1:rows(accumInit)], accumInit(:, i))
    end
  endif

  if (fig(5)||allFigs)
    figure(5); clf; hold on; grid on;
    period = 10;
    Nsamples = period*(fs/f0);
    zoom on;
    plotMic = [30 31 32 33];
    for i = 1:length(plotMic)
      plot(allOkValues(1:Nsamples,plotMic(i)), '-*')
    end
    legend(int2str(plotMic(1)), int2str(plotMic(2)), int2str(plotMic(3)), int2str(plotMic(4)))
  end

  if (fig(6)||allFigs)
    figure(6); clf; hold on; grid on;
    zoom on;
    period = 10;
    Nsamples = period*(fs/f0);
    plotMic = [2 26 52];
    for i = 1:length(plotMic)
      plot(allValues(60000:60000+Nsamples,plotMic(i)), '-*')
    end
    %legend(int2str(plotMic(1)), int2str(plotMic(2)), int2str(plotMic(3)), int2str(plotMic(4)))
  end

  if (fig(7)||allFigs)
    figure(7); clf; hold on; grid on; zoom on;
    start_samp = 10;
    end_samp = 20000;
    plotMic = [30 31 32 33];
    %for i = 1:64
      %plot([start_samp:end_samp],allValues(start_samp:end_samp,2),'-')
    %end
    plot(allValues(:,2),'-')
  end

  if (fig(8)||allFigs)
    figure(8);
    clf;
    hold on;
    zoom on;
    for i = 1:2
      plot ((i-1)*rows(allValues(start_samp:end_samp,1))+[1:rows(allValues(start_samp:end_samp,1))], allValues(start_samp:end_samp,i))
    end
  end
end

function scaledValues = scaleMic(scale, allOkValues, micToScale)
  if (scale)
    s = max(allOkValues(1:60,micToScale+1))/max(allOkValues(1:60,micToScale));
    allOkValues(:,micToScale) = s*allOkValues(:,micToScale);
    scaledValues = allOkValues;
  else
    scaledValues = allOkValues;
  end
end

function writeToFile(write, filename, allOkValues)
    if (write)
    csvwrite(strcat(filename, 'Reduced', '.bin.txt'), allOkValues);
  endif
end