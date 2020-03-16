    function SolarThermalSim
%{
SolarThermalSim(vflow,panel,Ts)

Simulates a proposed solar thermal system design for residential space heating in Medford, Oregon.
The closed-loop active system consists of a storage tank separated from the collector array by a counter-flow heat exchanger.

Inputs:

vflow    = volumetric flowrate in collector loop [ml/s]
panel    = number of solar collectors used
Ts       = starting water storage temperature [C]

As a starting point, use SRCC tested collector volumetric flow rate (vflow = 76 ml/s).


Outputs:

Table and plot of water storage in both celsius and fahrenheit over 24 hours 
on a typical summer day (July 21) and a typical winter day (December 21)
in Microsoft Excel file "Solar Thermal Storage Temperature.xlsx"

NOTE:

Units are SI system.
All times are in solar time unless otherwise noted.
Collector tilt angles are assumed to be 15 degress larger than site latitude for winter performance.
Collector used is Thermo Technologies Mazdon 30, and gross area is used for simultaion.
Heat-transfer fluid is assumed to be 30% propylene glycol/water mix (SG=1.03, Cp=3914.7 J/kg*k).
Flowrate is assumed to be equal for collector and storage sides of heat exchanger.
Must have Microsoft Excel file "Ambient Temperature.xlsx" as SolarThermalSim pulls ambient temperature data from the file.
All equations are taken from "Solar Engineering of Thermal Processes, Fourth Edition"
%}

panel = 6;                              %Number of Mazdon 30 collectors
phi = 42.4;                             %Latitude, based on WBAN 24225 weather station data  [degrees]
beta = phi+23;                          %Collector tilt angle for good winter performance [degrees]
altitude = .4;                          %Approximate altitude of Medford Oregon site, in km, based on WBAN 24225 weather station data  [km]
SG = 1.03;                              %Specific gravity of 30% propylene glycol/water heat-transfer fluid (engineeringtoolbox.com)
Cp = 3915;                              %Specific heat of 30% propylene glycol/water (engineeringtoolbox.com)  [J/kg*C]
Cpw = 4180;                             %Specific heat of water at ~298 K (Fundamenals of Heat and Mass Transfer, 7th ed.)  [J/kg*C]
Ac = panel*4.581;                       %Collector area based on number of panels.  4.581 m^2 for one Mazdon 30 (SRCC, June 2003)  [m^2]
mw = Ac*75;                             %Mass of water in storage tank  [kg] (75 liters/m2, 1 kg/liter) (based on range of 50-100 liters/m2 in Solar engineering of Thermal Processes, 4th ed.)
vflow = 76*3600;                        %recommended volumetric flowrate of Mazdon 30 from SRCC testing [ml/h] (SRCC, June 2003)
Frta = .53;                             %Collector optical efficiency for Mazdon 30 (SRCC, June 2003)
FrUl = 1.421*3600;                      %Collector loss coefficient for Mazdon 30 (SRCC, June 2003)  [J/m2*C*h]
mflowtest = (76/1000000)*1000*3600;     %Tested flow rate of Mazdon 30 with water [ml/s] (SRCC, June 2003) converted from ml/s to kg/h
Di = .01905;                            %3/4 inch pipe diameter, inner pipe diameter  [m]
Do = Di + (2*.025);                     %25mm thick insulation, making outside diameter pipe + 25mm on both sides  [m]
K = 0.026*3600;                         %Pipe insulation thermal conductivity for Urecon SunPipe, based on www.urecon.com  [J/m*C*h]
L = 12;                                 %Pipe run  [m]
%e = .75;                                %Heat exchanger effectiveness [75%]
pg = 0.2;                               %Ground reflectance, assumed .2 for year since there's very little snow fall, usually none
Th = 21;                                %Temperature house is maintained at [C] 
UA_s = 2*3600;                          %Storage loss coefficient-area product [J/C*h]
Hour = zeros(24,1);                     %-----------------------------------------------------
July21 = Hour;                          %
December21 = Hour;                      %
JulSolarLoad = Hour;                    %
DecSolarLoad = Hour;                    %
JulAuxLoad = Hour;                      %Preallocating space for column vectors in Excel table
DecAuxLoad = Hour;                      %
row1 = [0 0 0 0 0 0 0 40 0 40 0];       %
PumpJuly = Hour;                        %
PumpDecember = Hour;                    %
JulGt = Hour;                           %
DecGt = Hour;                           %
JulQu = Hour;                           %
DecQu = Hour;                           %
JulQuC = Hour;                          %
DecQuC = Hour;                          %
JulyLoad = Hour;                        %
DecLoad = Hour;                         %-----------------------------------------------------
%Qu1 = 0;                                %declaring variable for Utilizable energy with controls
pump = 0;                               %pump starts OFF
delta_Ton = 10;                         %Pump turn-on difference between collector outlet and storage temperatures  [C]
delta_Toff = 1;                         %Pump turn-off difference between collector outlet and storage temperatures  [C]
UA_hx = 850*3600;                       %Heat exchanger loss coefficient-area product [J/C*h]

%% Frta and FrUl corrections

%Capacitance rate (mCp) correction for Frta and FrUl
vflowc = vflow / 1000000;       %converts volumetric flow rate from ml/h to m^3/h
mflow = vflowc * 1000 * SG;     %converting volumetric flow rate to mass flow rate (kg/h) for glycol mix

FUl = (-mflowtest*Cpw/Ac) * log(1 - ((Ac*FrUl)/(mflowtest*Cpw)));   %J/m2*C*h
use = (mflow*Cp)/(Ac*FUl);                                          %dimensionless
test = (mflowtest*Cpw)/(Ac*FUl);                                    %dimensionless
r = (use * (1-exp(-1/use))) / (test * (1-exp(-1/test)));            %dimensionless
            
Frtar = Frta*r;     %dimensionless
FrUlr = FrUl*r;     %J/m2*C*h

%Piping correction for Frta and FrUl, FrTac and FrUlc
Ud=2*K/(Do*log(Do/Di));     %J/m2*C*h
Ai=pi*L*Di;                 %m2
Ao=pi*L*Do;                 %m2
tac=1/(1+Ud*Ao/(mflow*Cp)); %dimensionless
Ulc=(1 + Ud*Ai/(mflow*Cp) + Ud*(Ai+Ao)/(Ac*FrUl))/(1+Ud*Ao/(mflow*Cp)); %dimensionless

Frtac=Frtar*tac;    %dimensionless
FrUlc=FrUlr*Ulc;    %J/m2*C*h      

%Heat exchanger correction for Frtac and FrUlc, Frctac and FrcUlc. Cmin = C of collector.
C = (mflow * Cp) / (mflow * Cpw);                   %Capacitance Rate  [dimensionless]
NTU = UA_hx /(mflow * Cp);                          %Number of Transfer Units [dimensionless]
e = (1-exp(-NTU*(1-C))) / (1-C*(exp(-NTU*(1-C))));  %effectiveness [dimensionless]

Frc = (1 + (Ac*FrUlc/(mflow*Cp))*((mflow*Cp)/(e*mflow*Cp)-1))^(-1); %dimensionless
Frctac = Frtac*Frc;     %dimensionless
FrcUlc = FrUlc*Frc;     %J/m2*C*h

%% Day loop
for n = [ 202 355 ] 
    
    %Declination for day n, degrees
    b = (n-1) * (360/365);
    delta = (180/pi)*(.006918-.399912*cosd(b)+.070257*sind(b)-.006758*cosd(2*b)+.000907*sind(2*b)-.002697*cosd(3*b)+.00148*sind(3*b));
    
    %extraterrestrial radiation flux for day n, J/m2*h
    Gon = 1367 * 3600 * (1.000110+.034221*cosd(b)+.001280*sind(b)+.000719*cosd(2*b)+.000077*sind(2*b));
    
    %Sunrise and Sunset times
    SunsetHourAngle = acosd(-tand(phi)*tand(delta));    %degrees
    SunsetTime = SunsetHourAngle*(4/60)+12;             %h
    SunriseTime = 12 - SunsetHourAngle*(4/60);          %h
    
    %r0, r1, and rk values for year
    if n == 202        %for July
        r0 = .97;
        r1 = .99;      %Midaltitude summer on table 2.8.1
        rk = 1.02;
    else               %for December
        r0 = 1.03;  
        r1 = 1.01;     %Midaltitude winter on table 2.8.1
        rk = 1;
    end

    %solving for beam and transmission coefficients a0, a1, and k. dimensionless
    a0 = r0 * (.4237 - .00821 * (6 - altitude)^2);
    a1 = r1 * (.5055 + .00595 * (6.5 - altitude)^2);
    k = rk * (.2711 + .01858 * (2.5 - altitude)^2);
    
    %Determining cell range from "Ambient Temperature.xlsx" for daily ambient temperature vector ambT
    if n == 202             
    range = 'B3:B26';
    else
    range = 'C3:C26';
    end
    
    %Calling ambient temperatres for day from "Ambient Temperature.xlsx"
    ambT = xlsread('Ambient Temperature.xlsx',range);
    %{
    if n == 202        %Average water mains temp for summer [C] (Medford Water Commission, www.medfordwater.org)
        Tm = 12.5;
    else               %Average water mains temp for winter [C] (www.medfordwater.org)
        Tm = 8.5;
    end
    %}
    %Starting Storage (Ts) and collector (Tc) Temperatures [C]
    Ts = 40;
    %{
    if n == 202
        Tc = 19.4;
    else
        Tc = 1.7;
    end
    %}
    %% Hour Loop
    for t = 1:24    %Iterates from 1am (hour 1) to mightnight (hour 24)         
        %% Irradiance calculation for time t
        
        %hour angle, omega, for each hour. degrees
        omega = (t-12) * 15;
        
        %cosine of zenith angle on day n for time t, degrees
        zenith = cosd(phi)*cosd(delta)*cosd(omega) + sind(phi)*sind(delta);

        %beam and diffuse transmittances, tau b and tau d. dimensionless
        taub = a0 + a1 * exp(-k / zenith);
        taud = .271 - .294 * taub;

        %horizontal beam and diffuse radiation, Gb and Gd. J/m2*h
        Gb = Gon * zenith * taub;
        Gd = Gon * zenith * taud;

        %northern hemisphere radiation ratio, Rb. dimensionless
        Rb = (cosd(phi - beta)*cosd(delta)*cosd(omega) + sind(phi - beta)*sind(delta)) / (cosd(phi)*cosd(delta)*cosd(omega) + sind(phi)*sind(delta));

        %total solar irradiance on tilted surface for time t, Gt. J/m2*h
        Gt = Gb * Rb + Gd * ((1 + cosd(beta))/2) + (Gb + Gd) * pg * ((1 - cosd(beta))/2);

        %Limiting Gt to positive values inbetween sunrise and sunset times and zero otherwise
        if (t < SunriseTime) || (SunsetTime < t) || (Gt < 0)
            Gt = 0;
        end
        
        %Storing Gt values in vectors from table
        if n == 202
            JulGt(t) = Gt;
        else
            DecGt(t) = Gt;
        end
        
        %% Collector Calculations/Controls
        
        %Angle of incidence, degrees
        theta = cosd(phi-beta)*cosd(delta)*cosd(omega)+sind(phi-beta)*sind(delta);
        
        %incidence angle modifier, Kta, for Mazdon 30 (SRCC June, 2003). dimensionless 
        Kta = 1 - .1441*((1/theta)-1) - .0948*((1/theta)-1)^2;
        
        %Putting ambient temp values from Excel file into variable per hour
        Ta=ambT(t);
        
        Qu=Ac*(Frctac*Gt*Kta - FrcUlc*(Ts - Ta));  %[J/h]
        
        if Qu<=0  %To restrict useful gain (Qu) to positive values
            Qu=0;
        end
        
        %Storing useful energy gain values in vectors for table
        if n == 202
            JulQu(t) = Qu;
        else
            DecQu(t) = Qu;
        end
        
        %Tc = Tc + (Gt / (3*SG*Cp)) - Ta
        if pump == 1
            Tc = (Qu/(mflow * Cp)) + Ts;
        else
            Tc = ((Ac*(Frtar*Gt*Kta - FrUlr*(Ts - Ta)))/(Cp*(.7*SG))) + Ts;
        end
        
        
        %Collector Temp equation 6.12.7
        %Tc = Ta + (Frctac*Gt/FrcUlc) - ((Frctac*Gt/FrcUlc) - (Tc - Ta)) * exp((-Ac*FrcUlc)/(Cp*(.7*SG)));
        
        %{
        NOTE: Tc is collector outlet temp.
              Piping assumed lossless, so Ts = Ti (collector inlet temp is equal to storage tank).
              Pump is ON when 1 and OFF when 0.
        %}
        
        if (Tc-Ts >= delta_Ton) && (pump == 0)
            pump = 1;    %turn pump ON
        elseif (Tc-Ts < delta_Toff) && (pump == 1)
            pump = 0;    %turn pump OFF
            Qu = 0;
        end              %else previous iteration's outcome
        
        if pump == 0
            Qu = 0;
        end
        
        %storing pump ON/OFF and useful gain values in vectors for table
        if n == 202
           PumpJuly(t) = pump;
           JulQuC(t) = Qu;
        else
           PumpDecember(t) = pump;
           DecQuC(t) = Qu;
        end
        
        %% Storage
        
        %Temperature of water storage room is assumed to be the average of house and ambient temperatures
        Tr = (Th + Ta) / 2;      %[C]
        
        %Calling hourly domestic hot water load profile (assuming summer and winter are equal)
        loadcurve = xlsread('Ambient Temperature.xlsx','E3:E26');
        
        load = loadcurve(t);        %load is the DHW load, J/h 

        %heat exchanger heat loss, J/h
        hx = e*(mflow*Cp)*(Ts - Th);
        
        if n == 202     %hx is the space heating load, in summer its zero
            hx = 0;
        end
        
        %storage heat loss, J/h
        storage = UA_s*(Ts-Tr);
        
        %Calculates new storage temperature for hour
        Ts_p = Ts + (1/(mw*Cpw)) * (Qu - storage - hx - load);
            
        %Storing results in vectors
        Ts = Ts_p;
        
        %Energy and power stored in storage tank
        %Ew = Cpw*(Ts-Th)*mw / 3600;   %[J]
        
        %Percent of average heating load met by solar, solar fraction
        solarfrac = (Qu / (hx + load)) * 100;
        
        if solarfrac < 0
            solarfrac = 0;
        end
        
        %Auxiliary Load Determination, W
        auxiliary = ((hx + load) - Qu) / 3600;
        
        if auxiliary < 0
            auxiliary = 0;
        end
        
        Hour(t) = t;
        
        if n == 202
            July21(t) = Ts;
            JulSolarLoad(t) = solarfrac;
            JulAuxLoad(t) = auxiliary;
            JulyLoad(t) = load;
        else
            December21(t) = Ts;
            DecSolarLoad(t) = solarfrac;
            DecAuxLoad(t) = auxiliary;
            DecLoad(t) = hx + load;
        end
        
    end     %Hour Loop
        
end         %Day Loop
%{
%Pump Plot
plot(Hour,PumpJuly,Hour,PumpDecember)
axis([0 25 0 1.1])
title('Pump Operation')
xlabel('Time [hour]')
ylabel('Pump Status (0: OFF, 1: ON)')
legend('July 21','December 21','location','eastoutside')
%}
T = table(Hour,JulGt,DecGt,JulQu,DecQu,JulQuC,DecQuC,July21,PumpJuly,December21,PumpDecember,JulyLoad,DecLoad,JulSolarLoad,JulAuxLoad,DecSolarLoad,DecAuxLoad);
xlswrite('Solar Thermal Simulation.xlsx',row1,'A2:K2');
writetable(T,'Solar Thermal Simulation.xlsx','Range','A3:Q26','WriteVariableNames',false);
end