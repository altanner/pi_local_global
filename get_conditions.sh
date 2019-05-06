#!/bin/bash

## curl data from sites
curl wttr.in/bristol?0T > /home/pi/weather/wttr_weather
curl wttr.in/moon?T > /home/pi/weather/wttr_moon
curl https://www.timeanddate.com/astronomy/uk/bristol > /home/pi/weather/tnd_astro
curl https://www.timeanddate.com/weather/uk/bristol > /home/pi/weather/tnd_weather

## parse out specifics
CONDITIONS=$(cat /home/pi/weather/wttr_weather | awk 'NR==3' | cut -c 16-);
TEMP=$(cat /home/pi/weather/wttr_weather | awk 'NR==4' | awk '{print $(NF-1), $NF }');
WIND=$(cat /home/pi/weather/wttr_weather | awk 'NR==5' | awk '{print $(NF-2), $(NF-1), $NF}');
WINDDIR=$(cat /home/pi/weather/tnd_weather | grep -m 1 -oP '(?<=Wind blowing from\s)\w+');
PRES=$(cat /home/pi/weather/tnd_weather | grep -o -P "Pressure: </span> .{0,9}" | grep -o ".........$");
VISI=$(cat /home/pi/weather/wttr_weather | awk 'NR==6' | awk '{print $(NF-1), $NF}');
PRECIP=$(cat /home/pi/weather/wttr_weather | awk 'NR==7' | awk '{print $(NF-1), $NF}');
HUM=$(cat /home/pi/weather/tnd_weather | grep -o -P "Humidity: </span> .{0,3}" | grep -o "...$");
DEW=$(cat /home/pi/weather/tnd_weather | grep -o -P "Dew Point: </span>.{0,11}" | grep -o "..........$");
SUNRISE=$(cat /home/pi/weather/tnd_astro | grep -o -P "Sunrise Today: </span><span class=three>.{0,5}" | grep -o ".....$");
SUNSET=$(cat /home/pi/weather/tnd_astro | grep -o -P "Sunset Today: </span><span class=three>.{0,5}" | grep -o ".....$");
MOONPHASE=$(cat /home/pi/weather/wttr_moon | awk 'NR==10' | awk '{print $(NF-2), $(NF-1), $NF}');
MOONRISE=$(cat /home/pi/weather/tnd_astro | grep -o -P "Moonrise Today: </span><span class=three>.{0,5}" | grep -o ".....$");
MOONSET=$(cat /home/pi/weather/tnd_astro | grep -o -P "Moonset Today: </span><span class=three>.{0,5}" | grep -o ".....$");
MOONPERCENT=$(cat /home/pi/weather/tnd_astro | grep -o -P "Moon: <span id=cur-moon.{0,13}" | grep -o ".....$" | sed "s/>//");

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
echo "Sky see :  $CONDITIONS     " > /home/pi/weather/conditions;
echo "Air feel :  $TEMP    " >> /home/pi/weather/conditions;
echo "Sky move :  $WIND from $WINDDIR°    " >> /home/pi/weather/conditions;
echo "Airiness :  $PRES    " >>/home/pi/weather/conditions;
echo "Optodist :  $VISI    " >> /home/pi/weather/conditions;
echo "$DROPLETS :  $PRECIP    " >> /home/pi/weather/conditions;
echo "Wettitude :  $HUM    " >> /home/pi/weather/conditions;
echo "$DEWPOINT :  $DEW     " >> /home/pi/weather/conditions;
echo "Sunsoar :  $SUNRISE, Sunsquirrel :  $SUNSET     " >> /home/pi/weather/conditions;
echo "Moonmove : $MOONRISE, Moonsnooze :  $MOONSET     " >> /home/pi/weather/conditions;
echo "Lunar faction :  $MOONPHASE ($MOONPERCENT)     " >> /home/pi/weather/conditions;
sed -i "s/°/'/" /home/pi/weather/conditions;
sed -i "s/Sky move :  ./Sky move : /" /home/pi/weather/conditions;
sed -i "s/<//g" /home/pi/weather/conditions;
sed -i "s/\.\./ ~ /" /home/pi/weather/conditions;
sed -i "s/&nbsp;/ /" /home/pi/weather/conditions;
