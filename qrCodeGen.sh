#!/bin/bash

# set default values to variables
img_flag=false
csv_flag=false
img_file=""
csv_file=""
position="left"
json_flag=false

# parse input parameters
while getopts ':hi:d:p:j' option
do
  case "${option}" in
        # help
    h)  echo -e "$(basename ${0}) - generate identifications with qrcode\n"
        echo -e "${0} [-h] [-i image_file] [-d data_file] [-p position] [-j]\n"
        echo "options:"
        echo "-h       show brief help"
        echo "-i       specify an image file (.png, .jpg or .jpeg)"
        echo "-d       specify a data file (.csv)"
        echo "-p       specify a position for the qrcode, must be 'left', 'right' or 'center' ('left' is default)"
        echo "-j       enable JSON format in qrcode"
        exit 0 ;;
        # if it is a file
    i)  if [ -f "${OPTARG}" ]
        then
          # verify if the image file has one of the supported extensions
          if [ "${OPTARG##*.}" = "png" ] || \
             [ "${OPTARG##*.}" = "jpg" ] || \
             [ "${OPTARG##*.}" = "jpeg" ]
          then
            img_file="${OPTARG}"
            img_flag=true
          else
            echo "Image file extension must be .png, .jpg or .jpeg." >&2
            exit 1
          fi
        else
          echo "File '${OPTARG}' not found." >&2
          exit 1
        fi ;;
        # if it is a file
    d)	if [ -f "${OPTARG}" ]
        then
          # verify if the data file has a csv extension
          if [ "${OPTARG##*.}" = "csv" ]
          then
            csv_file="${OPTARG}"
            csv_flag=true
          else
            echo "Data file extension must be .csv." >&2
            exit 1
          fi
        else
          echo "File '${OPTARG}' not found." >&2
          exit 1
        fi ;;
        # verify if the position input is valid
    p)	if [ "${OPTARG}" = "left" ] || \
           [ "${OPTARG}" = "right" ] || \
           [ "${OPTARG}" = "center" ]
        then
          position="${OPTARG}"
        else
          echo "Argument of -p must be 'left', 'right' or 'center'." >&2
          exit 1
        fi ;;
        # enable json format
    j)	json_flag='true' ;;
        # if user didn't enter the required argument
    :)	echo "-${OPTARG} requires an argument"
        exit 1 ;;
        # if anything else is typed
    *)	echo "Usage: ${0} [-h] [-i image_file] [-d data_file] [-p position] [-j]" >&2
        exit 1 ;;
  esac
done

# verify if the required arguments are set
if [ "${img_flag}" = false ] || [ "${csv_flag}" = false ]
then
  echo "Options -i and -f are required." >&2
  exit 1
fi

# get the values for the position
if [ "${position}" = "right" ]
then
  position=691
elif [ "${position}" = "center" ]
then
  position=392
else
  position=94
fi

# replace every separator ';' by ',' in case that the csv has ';'
# as field separator, and create a backup of the original file
sed -i.bak "s/;/,/g" "${csv_file}"

# qrcode image size
size=300
# number of lines in data file
n=$(wc -l "${csv_file}" | cut -d' ' -f1)

# create the output folders
qr_folder="qrcodes"
id_folder="identifications"
mkdir -p "${qr_folder}" "${id_folder}"

# go through every line, starting at 2 (1 is header)
for i in $(seq 2 ${n})
do
  # output the status
  echo -ne "Generating identifications $((${i}-1))/$((${n}-1))\r"
  # get the current line
  line=$(sed "${i}q;d" ${csv_file})

  # get the id, name and email from the current line, removing the quotes, if present
  id_code=$(echo ${line} | cut -d',' -f1 | sed "s/\"//g" | sed "s/'//g")
  name=$(echo ${line} | cut -d',' -f2 | sed "s/\"//g" | sed "s/'//g")
  email=$(echo ${line} | cut -d',' -f3 | sed "s/\"//g" | sed "s/'//g")
  # set the name to uppercase
  name="${name^^}"

  if [ "${json_flag}" = true ]
  then
    # get the values in json format
    string=$( jq -n \
              --arg ic "${id_code}" \
              --arg nm "${name}" \
              --arg em "${email}" \
              '{id: $ic, name: $nm, email: $em}' )
  else
    # get the values separated by comma
    string=$(echo "${name},${id_code},${email}")
  fi

  # download the qrcode from the google api
  wget -q "chart.apis.google.com/chart?cht=qr&chs="${size}"x"${size}"&chl=${string}"
  # move and rename the qrcode file
  mv chart* "${qr_folder}/${name}.png"
  # add the qrcode image to the template image at the chosen position
  convert "${img_file}" "${qr_folder}/${name}.png" \
          -geometry +"${position}"+94 -composite tmp.png
  # add the name to the image and save it
  convert tmp.png -stroke none -fill black -pointsize 46 -font \
          "/home/${USER}/.fonts/RobotoCondensed-Regular.ttf" \
          -annotate +125+590 "${name}" "${id_folder}/${name}.png"
done

# remove temporary file
rm tmp.png
