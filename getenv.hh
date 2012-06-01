#ifndef TEST_GETENV_HH
#define TEST_GETENV_HH

#include <mozart.hh>

namespace test {

using mozart::builtins::In;
using mozart::builtins::Out;

struct ModGetEnv : mozart::builtins::Module
{
    ModGetEnv() : mozart::builtins::Module("GetEnv") {}

    struct GetEnv : mozart::builtins::Builtin<GetEnv>
    {
        GetEnv() : Builtin("getenv") {};

        mozart::OpResult operator()(mozart::VM vm, In key, Out value);
    };
};

}

#endif

