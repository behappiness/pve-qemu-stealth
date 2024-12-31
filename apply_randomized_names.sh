export QUILT_PATCHES=../debian/patches
export QUILT_REFRESH_ARGS="-p ab --no-timestamps --no-index"

cd qemu
quilt upgrade
quilt push -a

##################################################
## Spoofing USB Serial Numbers
##################################################

# Find files and process them
find "$(pwd)/hw/usb" -type f -exec grep -l '\[STR_SERIALNUMBER\]' {} + | while IFS= read -r file; do
    # Generate a new random serial number
    NEW_SERIAL=$(head /dev/urandom | tr -dc 'A-Z0-9' | head -c 10)

    # Replace all serial number strings in the files
    sed -i -E "s/(\[STR_SERIALNUMBER\] *= *\")[^\"]*/\1$NEW_SERIAL/" "$file"

    # Print the modification information
    echo -e "\e[32m  Modified:\e[0m '$file' with new serial: \e[32m$NEW_SERIAL\e[0m"
done

##################################################
## Spoofing MAC Address
## TODO
## 
##################################################

##################################################
## Spoofing Drive Serial Number String
##
## qemu/hw/ide/core.c
##################################################

# Define the core file path
core_file="$(pwd)/hw/ide/core.c"

# Generate a new random serial number
NEW_SERIAL=$(head /dev/urandom | tr -dc 'A-Z0-9' | head -c 15)

# Arrays of model strings
IDE_CD_MODELS=(
    "HL-DT-ST BD-RE WH16NS60"
    "HL-DT-ST DVDRAM GH24NSC0"
    "HL-DT-ST BD-RE BH16NS40"
    "HL-DT-ST DVD+-RW GT80N"
    "HL-DT-ST DVD-RAM GH22NS30"
    "HL-DT-ST DVD+RW GCA-4040N"
    "Pioneer BDR-XD07B"
    "Pioneer DVR-221LBK"
    "Pioneer BDR-209DBK"
    "Pioneer DVR-S21WBK"
    "Pioneer BDR-XD05B"
    "ASUS BW-16D1HT"
    "ASUS DRW-24B1ST"
    "ASUS SDRW-08D2S-U"
    "ASUS BC-12D2HT"
    "ASUS SBW-06D2X-U"
    "Samsung SH-224FB"
    "Samsung SE-506BB"
    "Samsung SH-B123L"
    "Samsung SE-208GB"
    "Samsung SN-208DB"
    "Sony NEC Optiarc AD-5280S"
    "Sony DRU-870S"
    "Sony BWU-500S"
    "Sony NEC Optiarc AD-7261S"
    "Sony AD-7200S"
    "Lite-On iHAS124-14"
    "Lite-On iHBS112-04"
    "Lite-On eTAU108"
    "Lite-On iHAS324-17"
    "Lite-On eBAU108"
    "HP DVD1260i"
    "HP DVD640"
    "HP BD-RE BH30L"
    "HP DVD Writer 300n"
    "HP DVD Writer 1265i"
)

IDE_CFATA_MODELS=(
    "SanDisk Ultra microSDXC UHS-I"
    "SanDisk Extreme microSDXC UHS-I"
    "SanDisk High Endurance microSDXC"
    "SanDisk Industrial microSD"
    "SanDisk Mobile Ultra microSDHC"
    "Samsung EVO Select microSDXC"
    "Samsung PRO Endurance microSDHC"
    "Samsung PRO Plus microSDXC"
    "Samsung EVO Plus microSDXC"
    "Samsung PRO Ultimate microSDHC"
    "Kingston Canvas React Plus microSD"
    "Kingston Canvas Go! Plus microSD"
    "Kingston Canvas Select Plus microSD"
    "Kingston Industrial microSD"
    "Kingston Endurance microSD"
    "Lexar Professional 1066x microSDXC"
    "Lexar High-Performance 633x microSDHC"
    "Lexar PLAY microSDXC"
    "Lexar Endurance microSD"
    "Lexar Professional 1000x microSDHC"
    "PNY Elite-X microSD"
    "PNY PRO Elite microSD"
    "PNY High Performance microSD"
    "PNY Turbo Performance microSD"
    "PNY Premier-X microSD"
    "Transcend High Endurance microSDXC"
    "Transcend Ultimate microSDXC"
    "Transcend Industrial Temp microSD"
    "Transcend Premium microSDHC"
    "Transcend Superior microSD"
    "ADATA Premier Pro microSDXC"
    "ADATA XPG microSDXC"
    "ADATA High Endurance microSDXC"
    "ADATA Premier microSDHC"
    "ADATA Industrial microSD"
    "Toshiba Exceria Pro microSDXC"
    "Toshiba Exceria microSDHC"
    "Toshiba M203 microSD"
    "Toshiba N203 microSD"
    "Toshiba High Endurance microSD"
)

DEFAULT_MODELS=(
    "Samsung SSD 970 EVO 1TB"
    "Samsung SSD 860 QVO 1TB"
    "Samsung SSD 850 PRO 1TB"
    "Samsung SSD T7 Touch 1TB"
    "Samsung SSD 840 EVO 1TB"
    "WD Blue SN570 NVMe SSD 1TB"
    "WD Black SN850 NVMe SSD 1TB"
    "WD Green 1TB SSD"
    "WD My Passport SSD 1TB"
    "WD Blue 3D NAND 1TB SSD"
    "Seagate BarraCuda SSD 1TB"
    "Seagate FireCuda 520 SSD 1TB"
    "Seagate One Touch SSD 1TB"
    "Seagate IronWolf 110 SSD 1TB"
    "Seagate Fast SSD 1TB"
    "Crucial MX500 1TB 3D NAND SSD"
    "Crucial P5 Plus NVMe SSD 1TB"
    "Crucial BX500 1TB 3D NAND SSD"
    "Crucial X8 Portable SSD 1TB"
    "Crucial P3 1TB PCIe 3.0 3D NAND NVMe SSD"
    "Kingston A2000 NVMe SSD 1TB"
    "Kingston KC2500 NVMe SSD 1TB"
    "Kingston A400 SSD 1TB"
    "Kingston HyperX Savage SSD 1TB"
    "Kingston DataTraveler Vault Privacy 3.0 1TB"
    "SanDisk Ultra 3D NAND SSD 1TB"
    "SanDisk Extreme Portable SSD V2 1TB"
    "SanDisk SSD PLUS 1TB"
    "SanDisk Ultra 3D 1TB NAND SSD"
    "SanDisk Extreme Pro 1TB NVMe SSD"
)

# Function to get a random element from an array
get_random_element() {
    local array=("$@")
    echo "${array[RANDOM % ${#array[@]}]}"
}

# Select random models
NEW_IDE_CD_MODEL=$(get_random_element "${IDE_CD_MODELS[@]}")
NEW_IDE_CFATA_MODEL=$(get_random_element "${IDE_CFATA_MODELS[@]}")
NEW_DEFAULT_MODEL=$(get_random_element "${DEFAULT_MODELS[@]}}")

# Replace the "QM" string with the new serial number in core.c
sed -i -E "s/\"[^\"]*%05d\", s->drive_serial\);/\"$NEW_SERIAL%05d\", s->drive_serial\);/" "$core_file"

# Spoof the IDE_CD drive model string
sed -i -E "s/\"HL-DT-ST BD-RE WH16NS60\"/\"$NEW_IDE_CD_MODEL\"/" "$core_file"

# Spoof the IDE_CFATA drive model string
sed -i -E "s/\"MicroSD J45S9\"/\"$NEW_IDE_CFATA_MODEL\"/" "$core_file"

# Spoof the default drive model string
sed -i -E "s/\"Samsung SSD 980 500GB\"/\"$NEW_DEFAULT_MODEL\"/" "$core_file"

# Print the modification information
echo -e "\e[32m  Modified:\e[0m '$core_file' with new serial: \e[32m$NEW_SERIAL\e[0m"
echo -e "\e[32m  Modified:\e[0m '$core_file' with new IDE_CD model: \e[32m$NEW_IDE_CD_MODEL\e[0m"
echo -e "\e[32m  Modified:\e[0m '$core_file' with new IDE_CFATA model: \e[32m$NEW_IDE_CFATA_MODEL\e[0m"
echo -e "\e[32m  Modified:\e[0m '$core_file' with new default model: \e[32m$NEW_DEFAULT_MODEL\e[0m"


##################################################
## Spoofing ACPI Table Strings
##
## qemu/include/hw/acpi/aml-build.h
##################################################

# Array of ACPI Pairs
pairs=(
    'DELL  ' 'Dell Inc' # Dell
    'ALASKA' 'A M I '   # AMD
    'INTEL ' 'U Rvp   ' # Intel
    ' ASUS ' 'Notebook' # Asus
    'MSI NB' 'MEGABOOK' # MSI
    'LENOVO' 'TC-O5Z  ' # Lenovo
    'LENOVO' 'CB-01   ' # Lenovo
    'SECCSD' 'LH43STAR' # ???
    'LGE   ' 'ICL     ' # LG
)

# Generate a random index to select a pair
total_pairs=$((${#pairs[@]} / 2))
random_index=$((RANDOM % total_pairs * 2))

# Extract the randomly selected pair
appname6=${pairs[$random_index]}
appname8=${pairs[$random_index + 1]}

# Replace the "BOCHS" "BXPC" strings in aml-build.h
file="$(pwd)/include/hw/acpi/aml-build.h"
sed -i "s/^#define ACPI_BUILD_APPNAME6 \".*\"/#define ACPI_BUILD_APPNAME6 \"$appname6\"/" "$file"
sed -i "s/^#define ACPI_BUILD_APPNAME8 \".*\"/#define ACPI_BUILD_APPNAME8 \"$appname8\"/" "$file"

# Print the modifications
echo -e "\e[32m  Modified:\e[0m '$file' with new values:"
echo -e "  \e[32m#define ACPI_BUILD_APPNAME6 \"$appname6\"\e[0m"
echo -e "  \e[32m#define ACPI_BUILD_APPNAME8 \"$appname8\"\e[0m"


##################################################
## Spoofing CPUID Manufacturer Signature Strings
## https://en.wikipedia.org/wiki/CPUID
## qemu/target/i386/kvm/kvm.c
##################################################

# Define the file path
kvm_file="$(pwd)/target/i386/kvm/kvm.c"

# Obtain the CPU Vendor ID
vendor_id=$(lscpu | awk -F': +' '/Vendor ID/ {print $2}')

# Replace the signature strings in kvm.c
sed -i -E "s/(memcpy\(signature, \")[^\"]*(\", 12\);)/\1$vendor_id\2/" "$kvm_file"

# Print the modification information
echo -e "\e[32m  Modified:\e[0m '$kvm_file' with new signature: \e[32m$vendor_id\e[0m"


##################################################
## Spoofing CPUID Manufacturer Model Name Strings
## https://en.wikipedia.org/wiki/CPUID
## qemu/hw/i386/pc_q35.c
##################################################

# Define the file path
q35_file="$(pwd)/hw/i386/pc_q35.c"

# Obtain the CPU Model Name
# model_name=$(lscpu | awk -F': +' '/Model name/ {print $2}')

# Replace the model name strings in pc_q35.c
# sed -i -E "s/(DEFINE_Q35_MACHINE\(v[0-9]+_[0-9]+, \")[^\"]+(\", NULL,)/\1$model_name\2/g" "$q35_file"

# Print the modification information
# echo -e "\e[32m  Modified:\e[0m '$q35_file' with new signature: \e[32m$model_name\e[0m"

##################################################

# Obtain the CPU Model Name
manufacturer=$(dmidecode -t 4 | grep 'Manufacturer:' | awk -F': +' '{print $2}')

# Replace the Manufacturer string in pc_q35.c
sed -i "s/smbios_set_defaults(\"[^\"]*\",/smbios_set_defaults(\"$manufacturer\",/" "$q35_file"

# Print the modification information
echo -e "\e[32m  Modified:\e[0m '$q35_file' with new signature: \e[32m$manufacturer\e[0m"

##################################################

quilt refresh
quilt pop -a
cd ..