% número de dias
numDays = numel(dailySummaries);

% pré-aloca vetores
landings   = zeros(1, numDays);
takeoffs   = zeros(1, numDays);
cruises    = zeros(1, numDays);
goarounds  = zeros(1, numDays);

% percorre cada dia e extrai os contadores
for k = 1:numDays
    s = dailySummaries{k}.summary;
    landings(k)  = s.nLandings;                 % contagem de landings
    takeoffs(k)  = s.nTakeoffs;                 % contagem de take-offs
    cruises(k)   = s.nCruises;                  % contagem de cruise
    goarounds(k) = s.nGoArounds;     % contagem de go-arounds
end

% eixo x: dias de 1 a 31
dias = 1:numDays;

% faz o plot
figure;
plot(dias, landings,  '-o', 'DisplayName','Landings');    hold on;
plot(dias, takeoffs,  '-o', 'DisplayName','Take-offs');
plot(dias, cruises,   '-o', 'DisplayName','Cruises');
plot(dias, goarounds, '-o', 'DisplayName','Go-Arounds');
hold off;

% formata
xlabel('Dia do mês');
ylabel('Número de voos');
title('Fases de voo diárias (jan25)');
legend('Location','best');
grid on;
