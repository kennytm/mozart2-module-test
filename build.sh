#!/bin/sh

if [ -z $MOZART_SRC_DIR ]; then
    MOZART_SRC_DIR=../mozart2
fi
if [ -z $MOZART_DIR ]; then
    MOZART_DIR=$MOZART_SRC_DIR/build/debug
fi
if [ -z $MOZART_LIB_DIR ]; then
    MOZART_LIB_DIR=../mozart2-library
fi
if [ -z $BOOTCOMPILER_DIR ]; then
    BOOTCOMPILER_DIR=../mozart2-bootcompiler
fi
if [ -z $2 ]; then
    HH_NAME=getenv
else
    HH_NAME=$2
fi

OZBC="java -jar $BOOTCOMPILER_DIR/target/scala-2.9.1/bootcompiler_2.9.1-2.0-SNAPSHOT-one-jar.jar"
CXX="g++ -std=c++11 -I$MOZART_DIR/vm/main -I$MOZART_DIR/boostenv/main -I$HH_NAME.out -I."
ALL_OZ_ARRAY=(Test
              $MOZART_LIB_DIR/init/Init
              $MOZART_SRC_DIR/boostenv/lib/OS
              $MOZART_LIB_DIR/sys/Property
              $MOZART_LIB_DIR/sys/System
              $MOZART_LIB_DIR/dp/URL
              $MOZART_LIB_DIR/support/DefaultURL)
ALL_OZ="${ALL_OZ_ARRAY[@]} "

FIN_MSG="\033[1;31mDone\033[0m"
NON_MSG="\033[1;30mNo need\033[0m"

case $1 in

    clean)
        rm -rf $HH_NAME.out
        rm -f *.out*
        rm -f *.o
        ;;

    build)
        echo -n "Generating JSON file for $HH_NAME... "
        if [ ! -f $HH_NAME.out.astbi ]; then
            clang++ -std=c++11 -stdlib=libc++ -S \
                -I$MOZART_DIR/vm/main \
                -femit-ast \
                -DMOZART_BUILTIN_GENERATOR \
                -o $HH_NAME.out.astbi \
                $HH_NAME.hh
            mkdir $HH_NAME.out
            $MOZART_DIR/generator/main/generator builtins $HH_NAME.out.astbi $HH_NAME.out/ ${HH_NAME}builtins
            echo -e $FIN_MSG
        else
            echo -e $NON_MSG
        fi

        echo -n "Compiling $HH_NAME.cc... "
        if [ ! -f $HH_NAME.o ]; then
            $CXX -c -o $HH_NAME.o $HH_NAME.cc
            echo -e $FIN_MSG
        else
            echo -e $NON_MSG
        fi

        echo -n "Compiling base environment... "
        if [ ! -f Base.o ]; then
            $OZBC --baseenv \
                -o Base.out.cc \
                -h boostenv.hh \
                -h $HH_NAME.hh \
                -m $MOZART_DIR/vm/main \
                -m $MOZART_DIR/boostenv/main \
                -m $HH_NAME.out \
                -b baseenv.out.txt \
                $MOZART_LIB_DIR/base/Base.oz \
                $MOZART_LIB_DIR/boot/BootBase.oz
            echo -n "(C++)... "
            $CXX -c -o Base.o Base.out.cc
            echo -e $FIN_MSG
        else
            echo -e $NON_MSG
        fi

        for name in $ALL_OZ; do
            echo -n "Compiling $name.oz... "
            BASENAME=`basename $name`
            if [ ! -f $BASENAME.o ]; then
                $OZBC \
                    -o $BASENAME.out.cc \
                    -h boostenv.hh \
                    -h $HH_NAME.hh \
                    -m $MOZART_DIR/vm/main \
                    -m $MOZART_DIR/boostenv/main \
                    -m $HH_NAME.out \
                    -b baseenv.out.txt \
                    $name.oz
                echo -n "(C++)... "
                $CXX -c -o $BASENAME.o $BASENAME.out.cc
                echo -e $FIN_MSG
            else
                echo -e $NON_MSG
            fi
        done

        echo -n "Compiling linker... "
        if [ ! -f Test.linked.o ]; then
            $OZBC --linker \
                -o Test.linked.out.cc \
                -h boostenv.hh \
                -h $HH_NAME.hh \
                -m $MOZART_DIR/vm/main \
                -m $MOZART_DIR/boostenv/main \
                -m $HH_NAME.out \
                -b baseenv.out.txt \
                ${ALL_OZ// /.oz }
            echo -n "(C++)... "
            $CXX -c -o Test.linked.o Test.linked.out.cc
            echo -e $FIN_MSG
        else
            echo -e $NON_MSG
        fi

        echo -n "Linking everything to a.out... "
        if [ ! -f a.out ]; then
            $CXX *.o \
                $MOZART_DIR/boostenv/main/libmozartvmboost.a \
                $MOZART_DIR/vm/main/libmozartvm.a \
                -lboost_system -lboost_filesystem -lboost_thread -pthread
            echo -e $FIN_MSG
        else
            echo -e $NON_MSG
        fi
        ;;

    *)
        echo "Usage:"
        echo "  $0 clean"
        echo "  $0 build [module]"
esac

