# Identification Generator with QR Codes

### Simple identification generator with QR Codes for events.

#### Status: Finished

[About](#about) | [Installation](#installation) | [Usage](#usage) | [Technologies](#technologies) | [License](#license)

## About

This shell script is an **identification generator** that has a QR Code to uniquely identify a person. It was originally created to the **SABER** (Semana Aberta de Informática - Informatics Open Week) at the Federal University of Paraná, but it's now adapted to a template in which anyone can generate an identification for any purposes. It uses a base image for the identification, which is in this repository and can be altered as much as you want, just **remember to maintain the position for the name box**. There is space to add a logo and some information.

Template for the background image:

<img src="example.png" width="542.5" height="380">

## Installation

To run this script you will need to have the following tools:

### Roboto Condensed Font Pack

Download the font pack:
```bash
wget -qO Roboto_Condensed.zip fonts.google.com/download?family=Roboto%20Condensed
```

Create the folder for fonts:
```bash
mkdir -p /home/${USER}/.fonts
```

Unzip the downloaded contents in the new folder:
```bash
unzip Roboto_Condensed.zip -x *.txt -d /home/${USER}/.fonts
```

Manually rebuild the font cache, so you can immediately use the fonts everywhere:
```bash
fc-cache -f -v
```

To verify if the installation was successful, just type `fc-list | grep "RobotoCondensed"`. If something shows up, it's installed.

### Dependencies

- **imagemagick:** free software suite for the creation, modification and display of bitmap images
- **jq:** command-line JSON processor

Execute the following command to install the dependencies of the script:

```bash
sudo apt update
sudo apt install imagemagick jq
```

## Usage

Give the correct permissions to run the script:
```bash
chmod u+x qrCodeGen.sh
```

Run the script using the following parameters:
```bash
./qrCodeGen.sh [-h] [-i image_file] [-d data_file] [-p position] [-j]
```

Example:
```bash
./qrCodeGen.sh -i example.png -d example.csv
```

### Parameters

More information about the parameters used:

- **-h:** show brief help
- **-i:** specify an image file (.png, .jpg or .jpeg)
- **-d:** specify a data file (.csv)"
- **-p:** specify a position for the QR Code, must be 'left', 'right' or 'center' ('left' is default)
- **-j:** enable JSON format in the QR Code

Only the image file (**-i**) and the data file (**-d**) are required parameters, the others are optional.

### Input files

As said before, there are two required files to run the script (image file and data file). The image file must have one of the supported extensions: png, jpg or jpeg. The data file must have the csv format and it can have unquoted items, single quoted items, double quoted items and a comma **','** or a semicolon **';'** as field separator (all those options are supported). The data file also need to be made of three columns, those columns being the **id**, the **name** and the **email** (in that order), the header **must** be included (otherwise the first line will be ignored) and there **must** be a blank line at the end of the file, as in the example below:

```
ID,NAME,EMAIL  
1770575,name-1,one@mail.com  
1588277,name-2,two@mail.com  
1968085,name-3,three@mail.com  
1458092,name-4,four@mail.com  
1342768,name-5,five@mail.com
  
```

## Technologies

- Shell ([bash](https://www.gnu.org/software/bash/))

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.