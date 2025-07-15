whereUsableResults = arrayfun(@(x) not(isempty(x.smootherMean)), results);
usableResults = results(whereUsableResults);
%flightPhaseDetection
%filterAcTypes (your preprocessing)
sector = [];
for iFlight = 1:numel(usableResults)
whereKeep = mod( second(datetime(usableResults(iFlight).smootherMean.time, 'Format','d-MMM-y HH:mm:ss.SSS')),1) == 0;
flightData = usableResults(iFlight).smootherMean(whereKeep,:);
flightData.callsign(:) = usableResults(iFlight).callsign;
sector = [sector; flightData];
end
sector = sortrows(sector,"time","ascend");
eddmCenter = [48.354017, 11.788711, 477];
NED = lla2ned([sector.lat, sector.lon, sector.h_QNH_Metar .* 0.3048],eddmCenter, 'flat');
sector.north = NED(:,1); sector.east = NED(:,2); sector.down = NED(:,3);
tic
t = unique(sector.time);
f = waitbar(0,"Calc Distance");
for iTime = 1:numel(t)
whereThisTime = sector.time == t(iTime);
thisSecondSmoother = sector(whereThisTime,:);
horizontalSeparation = pdist(thisSecondSmoother{:,["north", "east"]})./1852;
verticalSeparation = pdist(thisSecondSmoother.down) ./ 0.3048;
waitbar(iTime/numel(t),f)
end
toc
