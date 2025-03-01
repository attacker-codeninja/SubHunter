#!/bin/sh

GREEN='\033[0;32m'
BLUE='\033[0;34m'
UNDERLINE='\033[4m'
NC='\033[0m'

print_banner() {
    echo  "${GREEN}"
    echo '   ____     __   __ __          __         '
    echo '  / __/_ __/ /  / // /_ _____  / /____ ____'
    echo ' _\ \/ // / _ \/ _  / // / _ \/ __/ -_) __/'
    echo '/___/\_,_/_.__/_//_/\_,_/_//_/\__/\__/_/   '
    echo '                                            '
    echo  "${NC}"
}

print_main_menu() {
    echo ""
    echo "----------Main Menu---------"
    echo "1. Single input"
    echo "2. Multiple Input[".txt" "file"]"
    echo "3. Quit"
    echo "----------------------------"
}

handle_single_input() {
    read -p "Enter a website: " website
    output_file="${website}.txt"

    query="SELECT lower(NAME_VALUE) NAME_VALUE FROM certificate_and_identities WHERE plainto_tsquery('certwatch', '%$website%') @@ identities (CERTIFICATE) AND NAME_TYPE LIKE 'san:%';"

    (echo "$website"; echo "$query" | \
        psql --csv -t -h crt.sh -p 5432 -U guest certwatch | \
        grep '\.'"$website"'$' | grep -v '#\| ' | \
        sed -e 's:^*\.::g' -e 's:.*@::g' -e 's:^\.::g') | sort -u > "$output_file"

    echo "Subdomains for $website retrieved and saved to $output_file"

    back_to_main_menu
}

handle_input_file() {
    read -p "Enter the path to the input file: " file

    while IFS= read -r website; do
        output_file="${website}.txt"

        query="SELECT lower(NAME_VALUE) NAME_VALUE FROM certificate_and_identities WHERE plainto_tsquery('certwatch', '%$website%') @@ identities (CERTIFICATE) AND NAME_TYPE LIKE 'san:%';"

        (echo "$website"; echo "$query" | \
            psql --csv -t -h crt.sh -p 5432 -U guest certwatch | \
            grep '\.'"$website"'$' | grep -v '#\| ' | \
            sed -e 's:^*\.::g' -e 's:.*@::g' -e 's:^\.::g') | sort -u > "$output_file"

        echo "Subdomains for $website retrieved and saved to $output_file"
        echo "-------------------------"
    done < "$file"

    back_to_main_menu
}

back_to_main_menu() {
    echo ""
    read -p "Press Enter to go back to the main menu..."
    main_menu
}

main_menu() {
    clear
    print_banner
    print_main_menu

    read -p "Choose an option: " option

    case "$option" in
        1)
            clear
            print_banner
            handle_single_input
            ;;
        2)
            clear
            print_banner
            handle_input_file
            ;;
        3)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            back_to_main_menu
            ;;
    esac
}

main_menu

