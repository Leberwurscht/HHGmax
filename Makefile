.PHONY: all
all: lewenstein.so

lewenstein.so:
	g++ -shared -o lewenstein.so lewenstein.cpp -fPIC -fopenmp -O3 -ansi
