#ifndef TEST_GETENV_HH
#define TEST_GETENV_HH

#include <mozart.hh>

namespace test {

using mozart::builtins::In;
using mozart::builtins::Out;
using mozart::builtins::Module;
using mozart::builtins::Builtin;
using mozart::VM;

#ifndef MOZART_BUILTIN_GENERATOR
#include "getenvbuiltins.hh"
#endif

struct ModGetEnv : Module
{
    ModGetEnv() : Module("GetEnv") {}

    struct GetEnv : Builtin<GetEnv>
    {
        GetEnv() : Builtin("getenv") {};

        void operator()(VM vm, In key, Out value);
    };
};

}

#endif

