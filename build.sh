#!/bin/sh

if [ -z $MOZART_DIR ]; then
    MOZART_DIR=../mozart2/build/debug
fi
if [ -z $BOOTCOMPILER_DIR ]; then
    BOOTCOMPILER_DIR=../mozart2-bootcompiler
fi
if [ -z $2 ]; then
    HH_NAME=getenv
else
    HH_NAME=$2
fi

case $1 in

    clean)
        rm -rf mvm2.out
        rm -f *.out*
        ;;

    build)
        echo "Combining Base.oz into BaseBuilt.oz..."
        if [ ! -f Base.out.oz ]; then
            ./combine_base_oz.py $MOZART_DIR/lib/base/BaseBuilt.oz Base.oz > Base.out.oz
        fi

        echo "Cloning MVM2..."
        if [ ! -d mvm2.out ]; then
            cp -r $MOZART_DIR/vm/main mvm2.out
        fi

        echo "Generating JSON file for $HH_NAME..."
        if [ ! -f $HH_NAME.out.astbi ]; then
            clang++ -std=c++11 -stdlib=libc++ -Imvm2.out -femit-ast -S -o $HH_NAME.out.astbi $HH_NAME.hh
            $MOZART_DIR/generator/main/generator builtins $HH_NAME.out.astbi mvm2.out/
        fi

        echo "Compiling $HH_NAME.cc..."
        if [ ! -f $HH_NAME.o ]; then
            g++ -std=c++11 -Imvm2.out -c -o $HH_NAME.o $HH_NAME.cc
        fi

        echo "Translating Test.oz..."
        if [ ! -f Test.out.cc ]; then
            java -jar $BOOTCOMPILER_DIR/target/scala-2.9.1/bootcompiler_2.9.1-2.0-SNAPSHOT-one-jar.jar \
                -m mvm2.out -b Base.out.oz -o Test.out.cc Test.oz
        fi

        echo "Compiling everything to a.out..."
        if [ ! -f a.out ]; then
            g++ -std=c++11 -Imvm2.out Test.out.cc $HH_NAME.o mvm2.out/libmozartvm.a
        fi
        ;;

    *)
        echo "Usage:"
        echo "  $0 clean"
        echo "  $0 build [module]"
esac

