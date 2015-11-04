#!/bin/sh

TMP_METADATA_FILE="/tmp/_merge_sh_meta.dat"
TMP_PDF_OUTPUT="/tmp/_merge_sh_output.pdf"


change_drawing_title () {
    
    git diff --quiet --exit-code $1.pdf
    
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
        meta=$(pdftk CLKV2-DWG-$drawing_id.pdf dump_data)
        
        #### Extract title and number of pages info ####
        title=$(echo "$meta" | sed -n '/InfoKey/ {  N ; s/InfoKey: Title\nInfoValue: \(.*\)/\1/p }')
        num_pages=$(echo "$meta" | sed -n 's/NumberOfPages: \(.*\)/\1/p')
        
        #### Add current drawing to the bookmark data ####
        echo "BookmarkBegin" >> $TMP_METADATA_FILE
        echo "BookmarkTitle: $title" >> $TMP_METADATA_FILE
        echo "BookmarkLevel: 1" >> $TMP_METADATA_FILE
        echo "BookmarkPageNumber: $current_page" >> $TMP_METADATA_FILE
        
        input_files="$input_files CLKV2-DWG-$drawing_id.pdf"

        current_page=$(($current_page+$num_pages))
    done
    
    
    pdftk $input_files cat output $TMP_PDF_OUTPUT
    pdftk $TMP_PDF_OUTPUT update_info $TMP_METADATA_FILE output $1.pdf
}



####################################################
echo "Changing title metadata in pdf files..."

change_drawing_title "CLKV2-DWG-01" "RGB seven-segments digit - PCB" 
change_drawing_title "CLKV2-DWG-02" "RGB seven-segments digit - Diffuser shell" 
change_drawing_title "CLKV2-DWG-03" "RGB dot - PCB" 
change_drawing_title "CLKV2-DWG-04" "RGB dot - Diffuser shell" 
change_drawing_title "CLKV2-DWG-05" "RGB Digits display Base - PCB"
change_drawing_title "CLKV2-DWG-06" "RGB Dots Base - PCB" 
change_drawing_title "CLKV2-DWG-20" "RGB seven-segments digit assembly" 
change_drawing_title "CLKV2-DWG-21" "RGB dots assembly" 


####################################################
echo "Combining pdf files for model V2..."

combine_drawing_files "CLKV2-DWG" "01,02,20,03,04,21,05,06"
change_drawing_title "CLKV2-DWG" "Alarm clock V2"


echo        
echo "Done"