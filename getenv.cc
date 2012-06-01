#include <iostream>
#include <string>
#include <memory>
#include "getenv.hh"

static std::unique_ptr<char[]> to_utf8(const char16_t* input);
static std::unique_ptr<char16_t[]> to_utf16(const char* input);

#ifdef _LIBCPP_CODECVT

#include <codecvt>    // <-- GCC doesn't have <codecvt> yet.

static std::unique_ptr<char[]> to_utf8(const char16_t* input)
{
    std::codecvt_utf8_utf16<char16_t> cvt;

    size_t input_length = std::char_traits<char16_t>::length(input);
    size_t output_length = input_length * cvt.max_length();
    const char16_t* input_next;
    char* output_next;

    std::unique_ptr<char[]> output (new char[input_length + 1]);
    std::mbstate_t mb {};

    cvt.out(mb, input, input + input_length, input_next,
                output.get(), output.get() + output_length, output_next);
    *output_next = 0;

    return output;
}

static std::unique_ptr<char16_t[]> to_utf16(const char* input)
{
    std::codecvt_utf8_utf16<char16_t> cvt;

    size_t length = strlen(input);
    const char* input_next;
    char16_t* output_next;

    std::unique_ptr<char16_t[]> output (new char16_t[length + 1]);
    std::mbstate_t mb {};

    cvt.in(mb, input, input + length, input_next,
               output.get(), output.get() + length, output_next);
    *output_next = 0;

    return output;
}

#else

// Just a workaround...

static std::unique_ptr<char[]> to_utf8(const char16_t* input)
{
    size_t length = std::char_traits<char16_t>::length(input);
    std::unique_ptr<char[]> output (new char[length + 1]);

    for (size_t i = 0; i < length; ++ i)
        output[i] = input[i] & 0xff;
    output[length] = 0;

    return output;
}

static std::unique_ptr<char16_t[]> to_utf16(const char* input)
{
    size_t length = strlen(input);
    std::unique_ptr<char16_t[]> output (new char16_t[length + 1]);

    for (size_t i = 0; i < length; ++ i)
        output[i] = input[i];
    output[length] = 0;

    return output;
}


#endif

namespace test {

using namespace mozart;
using namespace mozart::builtins;

OpResult ModGetEnv::GetEnv::operator()(VM vm, In key, Out value)
{
    MOZART_CHECK_OPRESULT(requireLiteral(vm, key));

    auto key16 = key.as<Atom>().value()->contents();
    auto key8 = to_utf8(key16);

    auto value8 = getenv(key8.get());
    if (value8 == NULL)
    {
        value = trivialBuild(vm, unit);
    }
    else
    {
        auto value16 = to_utf16(value8);
        value = Atom::build(vm, value16.get());
    }

    return OpResult::proceed();
}

}

