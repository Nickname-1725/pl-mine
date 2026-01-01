
build/pl-mine: main.pl
	mkdir -p build
	swipl --goal=main --stand_alone=true -o build/pl-mine -c main.pl
