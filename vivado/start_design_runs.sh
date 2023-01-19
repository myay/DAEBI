cd ../rtl

# copy all vhdl files into build folder
for d in *;
do
    if [ -d "${d}" ];
    then
        if [ $d != "tcl_scripts" -a $d != "layout" -a $d != "build" -a $d != "vivado" -a $d != "popcount" ]
        then
            cd $d
            for filename in *.vhdl;
            do
                if [[ "$filename" != *"_tb"* ]];
                then
                    cp -R $filename ../../build/
                fi
            done
			cd ..
        fi
    fi
done

cd ..

COUNTER=0
# loop until python script returns errorlevel > 0
while [ $? -eq 0 ]
do
	# generate tcl script
	python vivado/gen_tcl.py -t vivado/automate_design_runs_template.tcl -o vivado/automate_design_runs.tcl -p vivado/param.txt -i $COUNTER
	if [ $? -ne 0 ]
	then
		echo "end of runs"
		break;
	fi

	# generate vhdl files (if needed)
	# currently generates popcount.vhdl while generating tcl script

	COUNTER=$[$COUNTER +1]
	
	# start design run
	vivado -mode tcl -source vivado/automate_design_runs.tcl
	
done