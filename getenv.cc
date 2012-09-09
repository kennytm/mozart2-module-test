#include <iostream>
#include <string>
#include <memory>
#include "getenv.hh"

namespace test {

using namespace mozart;
using namespace mozart::builtins;

void ModGetEnv::GetEnv::operator()(VM vm, In key, Out value)
{
    auto keyStr = vsToString<char>(vm, key);

    auto value8 = getenv(keyStr.c_str());
    if (value8 == NULL)
    {
        value = build(vm, unit);
    }
    else
    {
        value = build(vm, value8);
    }
}

#include "getenvbuiltins.cc"

}


