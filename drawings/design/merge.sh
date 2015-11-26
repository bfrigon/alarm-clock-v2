#!/bin/sh

TMP_METADATA_FILE="/tmp/_merge_sh_meta.dat"
TMP_PDF_OUTPUT="/tmp/_merge_sh_output.pdf"


change_drawing_title () {
    
    git diff-index --quiet --exit-code HEAD $1.pdf
    
    #### Check if the file was modified ####
    if [ $? -eq 1 ]; then
    
        echo "InfoBegin" > $TMP_METADATA_FILE
        echo "InfoKey: Title" >> $TMP_METADATA_FILE
        echo "InfoValue: $2" >> $TMP_METADATA_FILE
        echo "InfoBegin" >> $TMP_METADATA_FILE
        echo "InfoKey: Author" >> $TMP_METADATA_FILE
        echo "InfoValue: Benoit Frigon" >> $TMP_METADATA_FILE
    
        pdftk $1.pdf update_info $TMP_METADATA_FILE output $TMP_PDF_OUTPUT
        cp $TMP_PDF_OUTPUT $1.pdf
    fi
}

combine_drawing_files () {

    input_files=""
    current_page=1
    
    echo > $TMP_METADATA_FILE

    for drawing_id in $(echo $2 | tr "," "\n")
    do
        #### Dump metainfo from pdf ####
        meta=$(pdftk clkv2-dwg-$drawing_id.pdf dump_data)
        
        #### Extract title and number of pages info ####
        title=$(echo "$meta" | sed -n '/InfoKey/ {  N ; s/InfoKey: Title\nInfoValue: \(.*\)/\1/p }')
        num_pages=$(echo "$meta" | sed -n 's/NumberOfPages: \(.*\)/\1/p')
        
        #### Add current drawing to the bookmark data ####
        echo "BookmarkBegin" >> $TMP_METADATA_FILE
        echo "BookmarkTitle: $title" >> $TMP_METADATA_FILE
        echo "BookmarkLevel: 1" >> $TMP_METADATA_FILE
        echo "BookmarkPageNumber: $current_page" >> $TMP_METADATA_FILE
        
        input_files="$input_files clkv2-dwg-$drawing_id.pdf"

        current_page=$(($current_page+$num_pages))
    done
    
    
    pdftk $input_files cat output $TMP_PDF_OUTPUT
    pdftk $TMP_PDF_OUTPUT update_info $TMP_METADATA_FILE output $1.pdf
}



####################################################
echo "Changing title metadata in pdf files..."

change_drawing_title "clkv2-dwg-01" "RGB seven-segments digit - PCB" 
change_drawing_title "clkv2-dwg-02" "RGB seven-segments digit - Diffuser shell" 
change_drawing_title "clkv2-dwg-03" "RGB dot - PCB" 
change_drawing_title "clkv2-dwg-04" "RGB dot - Diffuser shell" 
change_drawing_title "clkv2-dwg-05" "RGB Digits display Base - PCB"
change_drawing_title "clkv2-dwg-06" "RGB Dots Base - PCB" 
change_drawing_title "clkv2-dwg-07" "Front panel PCB"
change_drawing_title "clkv2-dwg-08" "Touch keypad PCB"
change_drawing_title "clkv2-dwg-09" "Touch keypad enclosure"
change_drawing_title "clkv2-dwg-10" "Top panel vertical support"
change_drawing_title "clkv2-dwg-11" "Front panel bracket"
change_drawing_title "clkv2-dwg-12" "Motherboard PCB"
change_drawing_title "clkv2-dwg-13" "Enclosure"
change_drawing_title "clkv2-dwg-14" "Bottom cover"
change_drawing_title "clkv2-dwg-15" "Touch keypad overlay"
change_drawing_title "clkv2-dwg-20" "RGB seven-segments digit assembly" 
change_drawing_title "clkv2-dwg-21" "RGB dots assembly" 
change_drawing_title "clkv2-dwg-22" "Top panel assembly" 
change_drawing_title "clkv2-dwg-23" "Motherboard assembly" 
change_drawing_title "clkv2-dwg-24" "Arietta G25 assembly" 

####################################################
echo "Combining pdf files for model V2..."

combine_drawing_files "clkv2-dwg" "01,02,20,03,04,21,08,09,10,22,07,11,05,06"
change_drawing_title "clkv2-dwg" "Alarm clock V2"


echo        
echo "Done"