#!/bin/bash

destination_dir="${HOME}/simple_youtube_downloader_videos/"

if [ ! -d "${destination_dir}" ]; then
    mkdir -p "${destination_dir}";
fi

url_video="${1}";

filename="${destination_dir}"tmp.$(date +%Y%m%d_%H:%M);

wget -q "${url_video}" -O "${filename}";

title=$(grep -Eo "<title>.*<\/title>" "${filename}" | sed "s/&quot\;/\"/g;s/^<title>//g;s/<\/title>$//g;s/ /_/g");

sed -i 's/\\u0026/\&/g' "${filename}";

declare -a resolutions=($(grep -Eo "\{[^{]{1,}video\/mp4[^}]{1,}\}" "${filename}" | grep -oE "\"qualityLabel\":\"[0-9]{1,}p\"" | cut -d: -f2 | sed 's/^"//g;s/"$//g'));

number=0;
max_number=$(( ${#resolutions[*]} - 1 ));

echo -e "Choose resolution:"
for resolution in ${resolutions[*]}; do
    echo -e "\t$(echo $(( number ))) ${resolution}";
    number=$(( ++number ));
done

while read option; do
    if echo "${option}" | grep -Eqs "[0-${max_number}]{1,}"; then
        break;
    elif echo "${option}" | grep -Eqsi "^c$"; then
        echo "Bye!";
        exit 0;
    else
        echo "Please choose a number between 0 and ${max_number} or press C to cancel";
    fi
done

url=$(grep -Eo "\{[^{]{1,}video\/mp4[^}]{1,}}" "${filename}" | grep -E "\"qualityLabel\":\"${resolutions[$option]}\"" | grep -Eo "\"https:\/\/[^\"]{1,}\"" | sed 's/^"//g;s/"$//g');

wget -nv --show-progress "${url}" -O "${destination_dir}""${title}";

rm -rf "${filename}";
