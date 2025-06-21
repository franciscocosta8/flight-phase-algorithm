function tf = isValidFlight(callsign, airline, aircraftType, departures)
    % Returns TRUE if callsign and airline are valid identifiers.
    % Filters out empty, whitespace-only, literal '""', or placeholder strings.

    % Trim whitespace
    csTrim = strtrim(string(callsign));
    %alTrim = strtrim(string(airline));
    acTrim=strtrim(string(aircraftType));

    % Conditions for invalid ID
    condEmpty   = any(csTrim=="");   %|| (alTrim==""));
    condPlace   = any(startsWith(csTrim, "@@@", "IgnoreCase", true)); %|| startsWith(alTrim, "@@@", "IgnoreCase", true);
    condNoDepartures=isempty(departures);
    
    %Consider only Long range/wide-body/medium/short range/business jet aircraft and
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
        'E195'  ... % Embraer E195
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
];
    condAcType = ismember(acTrim, allowedTypes);
    
    tf = ~(condEmpty || condPlace || condNoDepartures) && condAcType;
end