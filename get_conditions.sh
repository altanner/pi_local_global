#!/bin/bash

## curl data from sites
curl wttr.in/bristol?0T > /home/pi/weather/wttr_weather
curl wttr.in/moon?T > /home/pi/weather/wttr_moon
curl https://www.timeanddate.com/astronomy/uk/bristol > /home/pi/weather/tnd_astro
curl https://www.timeanddate.com/weather/uk/bristol > /home/pi/weather/tnd_weather
curl https://www.metoffice.gov.uk/weather/warnings-and-advice/uk-storm-centre/index > /home/pi/weather/storms
curl https://earthquaketrack.com/recent > /home/pi/weather/quakes

## parse out specifics
CONDITIONS=$(cat /home/pi/weather/wttr_weather | awk 'NR==3' | cut -c 16-);
TEMP=$(cat /home/pi/weather/wttr_weather | awk 'NR==4' | awk '{print $(NF-1), $NF }');
WIND=$(cat /home/pi/weather/wttr_weather | awk 'NR==5' | awk '{print $(NF-2), $(NF-1), $NF}');
WINDDIR=$(cat /home/pi/weather/tnd_weather | grep -m 1 -oP '(?<=> from )\w+');
PRES=$(cat /home/pi/weather/tnd_weather | grep -o -P "Pressure: </span> .{0,9}" | grep -o ".........$");
VISI=$(cat /home/pi/weather/wttr_weather | awk 'NR==6' | awk '{print $(NF-1), $NF}');
PRECIP=$(cat /home/pi/weather/wttr_weather | awk 'NR==7' | awk '{print $(NF-1), $NF}');
HUM=$(cat /home/pi/weather/tnd_weather | grep -o -P "Humidity: </span> .{0,3}" | grep -o "...$");
DEW=$(cat /home/pi/weather/tnd_weather | grep -o -P "Dew Point: </span>.{0,11}" | grep -o "..........$");
SUNRISE=$(cat /home/pi/weather/tnd_astro | grep -o -P "Sunrise Today: </span><span class=three>.{0,5}" | grep -o ".....$");
SUNSET=$(cat /home/pi/weather/tnd_astro | grep -o -P "Sunset Today: </span><span class=three>.{0,5}" | grep -o ".....$");
MOONPHASE=$(cat tnd_astro | grep -o -P -m 1 "cur-moon-percent.{0,40}" | sed -e 's/.*p>\(.*\)<.*/\1/');
MOONRISE=$(cat /home/pi/weather/tnd_astro | grep -o -P "Moonrise Today: </span><span class=three>.{0,5}" | grep -o ".....$");
MOONSET=$(cat /home/pi/weather/tnd_astro | grep -o -P "Moonset Today: </span><span class=three>.{0,5}" | grep -o ".....$");
MOONPERCENT=$(cat /home/pi/weather/tnd_astro | grep -o -P "Moon: <span id=cur-moon.{0,13}" | grep -o ".....$" | sed "s/>//");
STORMNAME=$(tac /home/pi/weather/storms | grep -m 1 -B5 "/weather/warnings-and-advice/uk-storm-centre/storm-" | head -1 | sed "s/<*.td>//" | sed "s/[[:space:]]*//" | sed "s/<.td>//");
CO2=$(cat /home/pi/weather/co2 | grep "parts per million" | grep -m 1 -o -P "<strong>.{0,6}" | grep -o "......$");
QUAKELOC1=$(tac /home/pi/weather/quakes | grep -m 1 -B3 today | head -2 | tail -1 | sed -e 's/.*">\(.*\)<.*/\1/');
QUAKELOC2=$(tac /home/pi/weather/quakes | grep -m 1 -B3 today | head -1 | sed -e 's/.*">\(.*\)<.*/\1/');
QUAKEMM=$(tac /home/pi/weather/quakes | grep -m 1 today | sed -e 's/.*">\(.*\)<.*/\1/');
HOTCITY=$(cat hotcity | grep -o -P "<input type=hidden name=args value=\"sort=6\"></form></div></th></tr></thead><tr><td><a.{0,70}" | sed -e "s/.*\">//" | sed -e "s/<.*//");
HOTCITYTEMP=$(cat hotcity | grep -o -P -m 1 "</td><td class=rbi>.{0,2}" | head -1 | tail -c 3);

## if dew point is negative, change variable to frost point
DEWPOINT="Dew blossom";
if [[ $DEW == *"-"* ]]; then
    DEWPOINT="Frost blossom";
fi

## if temp below zero, precip is snow
DROPLETS="Droplets";
if [[ $TEMP == *"-"* ]]; then
    DROPLETS="Flurry flakes";
fi

## if visibility is maximum at 10km, call it horizon
if [[ $VISI == "10 km" ]]; then
    VISI="Horizon";
fi

## create conditions file
echo "Up see :  $CONDITIONS     " > /home/pi/weather/conditions;
echo "Air feel :  $TEMP    " >> /home/pi/weather/conditions;
echo "Sky move :  $WIND from $WINDDIR     " >> /home/pi/weather/conditions;
echo "Airiness :  $PRES    " >>/home/pi/weather/conditions;
echo "Optodist :  $VISI    " >> /home/pi/weather/conditions;
echo "$DROPLETS :  $PRECIP    " >> /home/pi/weather/conditions;
echo "Wettitude :  $HUM    " >> /home/pi/weather/conditions;
echo "$DEWPOINT :  $DEW     " >> /home/pi/weather/conditions;
echo "Sunsoar : $SUNRISE   Sunsquirrel :  $SUNSET     " >> /home/pi/weather/conditions;
echo "Moonloom : $MOONRISE   Moonsnooze :  $MOONSET     " >> /home/pi/weather/conditions;
echo "Lunar faction :  $MOONPHASE ($MOONPERCENT)     " >> /home/pi/weather/conditions;
echo "Future tempest :  $STORMNAME    " >> /home/pi/weather/conditions;
echo "Wobblemax : $QUAKEMM M, $QUAKELOC1, $QUAKELOC2     " >> /home/pi/weather/conditions;
echo "Sizzlecity : $HOTCITY $HOTCITYTEMP 'C     " >> /home/pi/weather/conditions;
echo "Doom sum : $CO2 ppm     " >> /home/pi/weather/conditions;

sed -i "s/°/'/" /home/pi/weather/conditions;
sed -i "s/Sky move :  ./Sky move : /" /home/pi/weather/conditions;
sed -i "s/<//g" /home/pi/weather/conditions;
sed -i "s/\.\./ ~ /" /home/pi/weather/conditions;
sed -i "s/&nbsp;/ /" /home/pi/weather/conditions;
