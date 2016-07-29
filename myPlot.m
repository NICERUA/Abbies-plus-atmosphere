function myPlot(X,F,auxOutput,extPar)
% Runs once at the end of each generation
disp('------ myPlot ------');

[FMin, index]=min(F);
XMin=X(:,index); % this has the parameters for the best chisquared of that generation 
                 % (between XMin and extPar), so this is the stuff i want to plot! vs original.
                 
auxMin=auxOutput{index};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% THIS IS WHAT IS AT THE FRONT OF THE FILE NAMES IN ALL SUBSEQUENT THINGS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Naming convention: Run + outdata file number + 'a' for first run with that outdata, 'b' for second, etc.
%filenameheader='Run2a';


%filename1=strcat('/Users/jasper/Documents/spot/run_data/',filenameheader,'_myPlot_best.txt');
%filename2=strcat('/Users/jasper/Documents/spot/run_data/',filenameheader,'_fitplot.ps');
%filename3=strcat('/Users/jasper/Documents/spot/run_data/',filenameheader,'_myPlot_fit.txt');
%filename4=strcat('/Users/jasper/Documents/spot/run_data/',filenameheader,'_myPlot_data.txt');

%%%% Printing the best fit parameters to a file
%fileID=fopen(filename1, 'a+');
%fprintf(fileID, 'M= %6f, R = %6f, i = %6f, e = %6f, p = %6f, ts = %6f \n', XMin(2), XMin(1), XMin(3), XMin(4), XMin(5), XMin(6));
%fprintf(fileID, 'chisquared = %8f \n\n', FMin);
%fclose(fileID);

% Getting data from imported data file
numbins = extPar.obsdata2.numbins;
data_time = extPar.obsdata2.t;
data_flux_1 = extPar.obsdata2.f(1,:); % low energy band
data_flux_2 = extPar.obsdata2.f(2,:); % high energy band
data_err_1 = extPar.obsdata2.err(1,:); % error in flux
data_err_2 = extPar.obsdata2.err(2,:); % error in flux
nothing = zeros(numbins,1); % no error in time

dt = transpose(data_time); % makes it a vertical array
df1 = transpose(data_flux_1); % makes it a vertical array
df2 = transpose(data_flux_2); % makes it a vertical array
de1 = transpose(data_err_1); % makes it a vertical array
de2 = transpose(data_err_2); % makes it a vertical array


dataM = horzcat(dt, df1, df2); % making a matrix of the data values
%disp(dataM);

% Getting the best fit from auxMin (printed to in SpotMex.cpp)
fit_time = auxMin(:,1);
fit_flux_1 = auxMin(:,2);
fit_flux_2 = auxMin(:,3);

fitM = horzcat(fit_time, fit_flux_1, fit_flux_2); % making a matrix of the fit values
%disp(fitM);

% Writing matrices to output files, for checking values
% not working when I want to put a few header lines in
%fitprint=fopen(filename3,'w+');
%fprintf(fitprint,'# Fit values from myPlot \n');
%fprintf(fitprint,'# Column 1: time \n# Column 2: Flux, first energy band \n# Column 3: Flux, second energy band \n');
%fprintf(fitprint,'# \n');
%fclose(fitprint);
%dlmwrite(filename3, fitM, '\t');
%dataprint=fopen(filename4,'w+');
%fprintf(dataprint,'# Data read into myPlot \n');
%fprintf(dataprint,'# Column 1: time \n# Column 2: Flux, first energy band \n# Column 3: Flux, second energy band \n');
%fprintf(dataprint,'# \n');
%fclose(dataprint);
%dlmwrite(filename4, dataM, '\t');


% For printing out to "User Plot" in the Ferret console

errorbar(dt,df2,nothing,de2);
hold on
plot(fit_time,fit_flux_2,'-m');

%print(h,'-dpsc2','-append',filename2);

%%%% Printing the best fit parameters to the Notes file, to show up in the Ferret window
%notes_file=fopen('/Users/abigail/Desktop/spot/FerretData/Notes.txt','a+');
%fprintf(notes_file, 'M= %6f \n R = %6f \n i = %6f \n e = %6f \n p = %6f \n ts = %6f \n', XMin(2), XMin(1), XMin(3), XMin(4), XMin(5), XMin(6));
%fprintf(notes_file, 'chisquared = %8f \n\n', FMin);
%fclose(notes_file);