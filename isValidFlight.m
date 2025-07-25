function tf = isValidFlight(callsign, airline, aircraftType, smootherMean)
    % Returns TRUE if callsign and airline are valid identifiers.
    % Filters out empty, whitespace-only, literal '""', or placeholder strings.

    % Trim whitespace
    csTrim = strtrim(string(callsign));
    alTrim = strtrim(string(airline));
    acTrim=strtrim(string(aircraftType));


    condEmpty = all(csTrim == "") && all(alTrim == "");
    hasCSPlace = any(startsWith(csTrim, "@@@", "IgnoreCase", true));
    hasALPlace = any(startsWith(alTrim, "@@@", "IgnoreCase", true));
    condPlace = hasCSPlace || hasALPlace;
    
    %Consider only Long range/wide-body/medium/short range/bs jet aircraft and
    %turbo-prop airliner/freighter
    %Data taken from Eurocontrol aircraft performance database
    
    % Long-range / Wide-body

    % Manufacturer: Airbus
    long_range_airbus = { ...
        'A306', ... % Airbus A300-600
        'A310', ... % Airbus A310
        'A332', ... % Airbus A330-200
        'A333', ... % Airbus A330-300
        'A338', ... % Airbus A330-800neo
        'A339', ... % Airbus A330-900neo
        'A345', ... % Airbus A340-500
        'A346', ... % Airbus A340-600
        'A359', ... % Airbus A350-900
        'A388', ... % Airbus A380-800
        'A3ST', ... % Airbus Beluga
        'A124'  ... % ANTONOV An-124 Ruslan (Note: This is likely a typo in the source, as An-74 is not a long-range Airbus aircraft)
    };
    
    % Manufacturer: Boeing
    long_range_boeing = { ...
        'B741', ... % Boeing 747-100
        'B742', ... % Boeing 747-200
        'B743', ... % Boeing 747-300
        'B744', ... % Boeing 747-400
        'B748', ... % Boeing 747-8
        'B77L', ... % Boeing 777-200LR
        'B77W', ... % Boeing 777-300ER
        'B788', ... % Boeing 787-8
        'B789', ... % Boeing 787-9
        'B78X'  ... % Boeing 787-10
        'B74D', ... % Boeing 747-400D
        'B752', ... % Boeing 752-200
        'B753', ... % Boeing 753-300
        'B762', ... % Boeing 767-200
        'B763', ... % Boeing 767-300
        'B764', ... % Boeing 767-400
        'B772', ... % Boeing 777-200
        'B773', ... % Boeing 777-300
        'B74R', ... % Boeing 747-SR
        'B74S'  ... % Boeing 747-SP
    };
    
    % Manufacturer: McDonnell Douglas
    long_range_mcDonnell_douglas = { ...
        'DC10', ... % McDonnell Douglas DC-10
        'MD11'  ... % McDonnell Douglas MD-11
    };
    
    
    %  Medium / Short-range jets
    
    % Manufacturer: Antonov
    med_short_range_antonov_jet = { ...
        'AN72'  ... % Antonov An-72
    };
    
    % Manufacturer: Airbus
    med_short_range_airbus = { ...
        'A19N', ... % Airbus A319neo
        'A20N', ... % Airbus A320neo
        'A21N', ... % Airbus A321neo
        'A318', ... % Airbus A318
        'A319', ... % Airbus A319
        'A320', ... % Airbus A320
        'A321'  ... % Airbus A321
    };
    
    % Manufacturer: ATR
    med_short_range_atr = { ...
        'AT76'  ... % ATR 72-600
    };
    
    % Manufacturer: Boeing
    med_short_range_boeing = { ...
        'B703', ... % Boeing 707-320
        'B712', ... % Boeing 717-200
        'B722', ... % Boeing 727-200
        'B732', ... % Boeing 737-200
        'B733', ... % Boeing 737-300
        'B734', ... % Boeing 737-400
        'B735', ... % Boeing 737-500
        'B736', ... % Boeing 737-600
        'B737', ... % Boeing 737-700
        'B738', ... % Boeing 737-800
        'B739', ... % Boeing 737-900
        'B37M', ... % Boeing 737 MAX 7
        'B38M', ... % Boeing 737 MAX 8
        'B39M', ... % Boeing 737 MAX 9
        'B3XM', ... % Boeing 737 MAX 10
    };
    
    % Manufacturer: Bombardier CSeries / Airbus A220
    med_short_range_bombardier_cseries = { ...
        'BCS1', ... % Airbus A220-100
        'BCS3'  ... % Airbus A220-300
    };
    
    % Manufacturer: Bombardier CRJ
    med_short_range_bombardier_crj = { ...
        'CRJ1', ... % Bombardier CRJ100
        'CRJ2', ... % Bombardier CRJ200
        'CRJ7', ... % Bombardier CRJ700
        'CRJ9', ... % Bombardier CRJ900
        'CRJX'  ... % Bombardier CRJ1000
    };
    
    % Manufacturer: Douglas
    med_short_range_douglas = { ...
        'DC91', ... % Douglas DC-9-10
        'DC92', ... % Douglas DC-9-20
        'DC93', ... % Douglas DC-9-30
        'DC94', ... % Douglas DC-9-40
        'DC95'  ... % Douglas DC-9-50
    };
    
    % Manufacturer: Dornier / Fairchild Dornier
    med_short_range_dornier = { ...
        'D328', ... % Dornier 328
        'J328'  ... % Fairchild Dornier 328JET
    };
    
    % Manufacturer: Embraer E-Jets
    med_short_range_embraer = { ...
        'E135', ... % Embraer ERJ 135
        'E145', ... % Embraer ERJ 145
        'E170', ... % Embraer E170
        'E190', ... % Embraer E190
        'E195',  ... % Embraer E195
        'E295' ... %EMBRAER E195-E2
    };
    
    % Manufacturer: Fokker
    med_short_range_fokker = { ...
        'F70',  ... % Fokker 70
        'F100'  ... % Fokker 100
    };
    
    % Manufacturer: McDonnell Douglas
    med_short_range_mcDonnell_douglas_MD = { ...
        'MD81', ... % McDonnell Douglas MD-81
        'MD82'  ... % McDonnell Douglas MD-82
    };
    

    business_jet = { ...
    'ASTR', ... % Astra by Israel Aerospace Industries (IAI)
    'BE40', ... % BEECH 400 Beechjet by HAWKER BEECHCRAFT
    'C25A', ... % Citation Jet CJ2/CJ2+ by CESSNA
    'C525', ... % 525 CitationJet, Citation CJ1 by CESSNA
    'C550', ... % 550 Citation II by CESSNA
    'C560', ... % 560 Citation V Ultra Encore by CESSNA
    'C56X', ... % 560XL Citation Excel by CESSNA
    'C650', ... % 650 Citation III/VI/VII by CESSNA
    'C68A', ... % Cessna Citation Latitude 
    'C680', ... % Citation Sovereign by CESSNA
    'C750', ... % 750 Citation X by CESSNA
    'CL30', ... % Challenger 300 by BOMBARDIER
    'CL60', ... % Challenger 600 series by BOMBARDIER
    'E50P', ... % Embraer Phenom 100
    'E55P', ... % Embraer Phenom 300
    'F2TH', ... % Dassault Falcon 2000
    'F900', ... % Dassault Falcon 900
    'FA10', ... % Dassault Falcon 10
    'FA20', ... % Dassault Falcon 20
    'FA50', ... % Dassault Falcon 50
    'FA7X', ... % Dassault Falcon 7X
    'G150', ... % Gulfstream G150
    'G280', ... % Gulfstream G280
    'GALX', ... % Gulfstream G200
    'GL5T', ... % Bombardier Global 5000
    'GLEX', ... % Bombardier Global Express
    'GLF3', ... % Gulfstream III
    'GLF4', ... % Gulfstream IV
    'GLF5', ... % Gulfstream V
    'H25A', ... % BAe 125 Series A (Hawker 800A)
    'H25B', ... % BAe 125 Series B (Hawker 800XP)
    'H25C', ... % BAe 125-1000 Series (Hawker 1000)
    'L29B', ... % Lockheed L-1329 Jetstar 2
    'LJ25', ... % Learjet 25
    'LJ31', ... % Learjet 31
    'LJ35', ... % Learjet 35/36
    'LJ40', ... % Learjet 40
    'LJ45', ... % Learjet 45
    'LJ55', ... % Learjet 55
    'LJ60', ... % Learjet 60
    'PRM1', ... % Piaggio P.180 Avanti I
    'S601', ... % Aérospatiale SN 601 Corvette
    'SBR2'  ... % North American NA-265 Sabre 75 Sabreliner
};
    
    
    turboprop = { ...
    'A748', ... % Hawker Siddeley HS 748
    'AN12', ... % Antonov An-12
    'AN22', ... % Antonov An-22
    'AN24', ... % Antonov An-24
    'AN26', ... % Antonov An-26
    'AN28', ... % Antonov An-28
    'AN30', ... % Antonov An-30
    'AN32', ... % Antonov An-32
    'AN38', ... % Antonov An-38
    'AN43', ... % Antonov An-140
    'AT44', ... % ATR 42-400 “Surveyor”
    'AT45', ... % ATR 42-500
    'AT72', ... % ATR 72 (-201/-202)
    'ATP',  ... % British Aerospace ATP
    'B190', ... % Beechcraft 1900/1900C/1900D
    'BE99', ... % Beechcraft Model 99
    'BE9L', ... % Beechcraft Premier IA
    'C212', ... % CASA/IPTN 212 Aviocar
    'CL2T', ... % Bombardier 415 “Superscooper”
    'CN35', ... % CASA/IPTN CN-235
    'D328', ... % Fairchild Dornier Do.328
    'DH8A', ... % De Havilland Canada DHC-8-100 Dash 8
    'DH8C', ... % De Havilland Canada DHC-8-300 Dash 8
    'DH8D', ... % De Havilland Canada DHC-8-400 Dash 8Q
    'DHC6', ... % De Havilland Canada DHC-6 Twin Otter
    'DHC7', ... % De Havilland Canada DHC-7 Dash 7
    'E120', ... % Embraer EMB 120 Brasilia
    'F27',  ... % Fokker F27 Friendship
    'F50',  ... % Fokker 50
    'IL18', ... % Ilyushin Il-18
    'JS1',  ... % Handley Page Jetstream 1
    'JS31', ... % British Aerospace Jetstream 31
    'JS32', ... % British Aerospace Jetstream 32
    'JS41', ... % British Aerospace Jetstream 41
    'L188', ... % Lockheed L-188 Electra
    'L410', ... % Let L-410 Turbolet
    'L610', ... % Let L-610
    'N262', ... % Nord 262 (Aerospatiale Nord 262)
    'SB20', ... % Saab 2000
    'SC7',  ... % Shorts SC-7 Skyvan
    'SF34', ... % Saab SF-340A/B
    'SH33', ... % Shorts SD-330
    'SH36'  ... % Shorts SD-360
};

%     utility_single = { ...
%     'AC11', ... % Rockwell Commander 112
%     'AN2',  ... % Antonov An-2
%     'BDOG', ... % Beagle B-125 Bulldog
%     'BE23', ... % Beechcraft Model 23 Musketeer
%     'BE33', ... % Beechcraft Model 33 Debonair
%     'BE36', ... % Beechcraft A36 Bonanza
%     'C06T', ... % Cessna 206 Turbo Stationair
%     'C150', ... % Cessna 150
%     'C152', ... % Cessna 152
%     'C172', ... % Cessna 172 Skyhawk
%     'C177', ... % Cessna 177 Cardinal
%     'C182', ... % Cessna 182 Skylane
%     'C206', ... % Cessna 206 Stationair
%     'C207', ... % Cessna 207 Stationair 7
%     'C208', ... % Cessna 208 Caravan
%     'C210', ... % Cessna 210 Centurion
%     'C82R', ... % Cessna 182RG Skylane RG
%     'CP23', ... % Cap Aviation CAP-230
%     'DA40', ... % Diamond DA40 Diamond Star
%     'DA50', ... % Diamond DA50 Super Star
%     'DR40', ... % Avions Robin DR400
%     'F26T', ... % Aermacchi SF-260TP
%     'G115', ... % Grob G-115 Tutor
%     'G3',   ... % Remos G-3 Mirage
%     'M18',  ... % PZL-Mielec M-18 Dromader
%     'M20P', ... % Mooney M-20
%     'M20T', ... % Mooney M-20M Bravo
%     'P28A', ... % Piper PA-28-140 Cherokee Cruiser
%     'P28R', ... % Piper PA-28R Arrow 3
%     'P28T', ... % Piper PA-28RT-201T Turbo Arrow 4
%     'P32R', ... % Piper PA-32R Lance
%     'P46T', ... % Piper PA-46-500TP Malibu Meridian
%     'PA18', ... % Piper PA-18 Super Cub
%     'PA32', ... % Piper PA-32 Cherokee Six
%     'PA38', ... % Piper PA-38 Tomahawk
%     'PA46', ... % Piper PA-46 Malibu Mirage
%     'PC12', ... % Pilatus PC-12
%     'PC6T', ... % Pilatus PC-6 Porter
%     'PC7',  ... % Pilatus PC-7 Turbo Trainer
%     'PZ04', ... % PZL-104 Wilga
%     'RALL', ... % Socata Rallye
%     'SR20', ... % Cirrus SR20
%     'TAMP', ... % Socata TB-9 Tampico
%     'TB30', ... % Socata TB-30 Epsilon
%     'TBM7', ... % Socata TBM 700
%     'TBM8', ... % Socata TBM 850
%     'TOBA', ... % Socata TB-10 Tobago
%     'TRIN', ... % TB-20/21 Trinidad
%     'TUCA'  ... % A-27
% };
% 
% 
%     utility_twin = { ...
%     'AC50', ... % Aero Commander 500
%     'AC56', ... % Aero Commander 560
%     'AC68', ... % Aero Commander 680
%     'AC6L', ... % Aero Commander 690
%     'AC95', ... % 695 Jetprop Commander 1000
%     'AEST', ... % Piper Aerostar
%     'B350', ... % Beechcraft Super King Air 350
%     'BE10', ... % Beechcraft King Air 100
%     'BE20', ... % Beechcraft King Air 200
%     'BE50', ... % Beechcraft Twin Bonanza
%     'BE55', ... % Beechcraft Baron 55
%     'BE58', ... % Beechcraft Baron 58
%     'BE60', ... % Beechcraft Duke 60
%     'BE70', ... % Beechcraft Queen Air 70
%     'BE76', ... % Beechcraft Duchess 76
%     'BE80', ... % Beechcraft Queen Air 80
%     'BE95', ... % Beechcraft Travel Air 95
%     'C303', ... % Cessna T303 Crusader
%     'C310', ... % Cessna 310
%     'C337', ... % Cessna 337 Skymaster
%     'C340', ... % Cessna 340
%     'C402', ... % Cessna 402
%     'C404', ... % Cessna 404 Titan
%     'C414', ... % Cessna 414 Chancellor
%     'C421', ... % Cessna 421 Golden Eagle
%     'C425', ... % Cessna 425 Corsair / Conquest I
%     'C441', ... % Cessna 441 Conquest II
%     'D228', ... % Dornier 228
%     'D28D', ... % Dornier 228-212
%     'DA42', ... % Diamond DA42 Twin Star
%     'E110', ... % Embraer EMB 110 Bandeirante
%     'E121', ... % Embraer EMB 121 Xingu
%     'F406', ... % Reims-Cessna F406 Caravan II
%     'JS20', ... % Handley Page Jetstream 200
%     'JS3',  ... % Century Jetstream 3
%     'MU2',  ... % Mitsubishi MU-2
%     'P180', ... % Piaggio P.180 Avanti
%     'PA23', ... % Piper PA-23 Apache/Aztec
%     'PA27', ... % Piper PA-27 Aztec
%     'PA31', ... % Piper PA-31 Navajo
%     'PA34', ... % Piper PA-34 Seneca
%     'PA44', ... % Piper PA-44 Seminole
%     'PAY2', ... % Piper Cheyenne 2
%     'PAY3', ... % Piper Cheyenne 3
%     'PAY4', ... % Piper Cheyenne IV
%     'SW2',  ... % Swearingen Merlin 2
%     'SW3',  ... % Swearingen Merlin 3
%     'SW4'    ... % Fairchild Swearingen Metroliner
% };

    allowedTypes = [ ...
    long_range_airbus(:); ...
    long_range_boeing(:); ...
    long_range_mcDonnell_douglas(:); ...
    med_short_range_antonov_jet(:); ...
    med_short_range_airbus(:); ...
    med_short_range_atr(:); ...
    med_short_range_boeing(:); ...
    med_short_range_bombardier_cseries(:); ...
    med_short_range_bombardier_crj(:); ...
    med_short_range_douglas(:); ...
    med_short_range_dornier(:); ...
    med_short_range_embraer(:); ...
    med_short_range_fokker(:); ...
    med_short_range_mcDonnell_douglas_MD(:); ...
    business_jet(:); ...
    turboprop(:); ...
    % utility_single(:); ...
    % utility_twin(:); ...
];
    condAcType = ismember(acTrim, allowedTypes);
    
    tf = ~(condEmpty || condPlace) && condAcType;
    %add smootherMean
    tf = tf&& ~isempty(smootherMean);
end