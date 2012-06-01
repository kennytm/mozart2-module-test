functor
require
    Boot_GetEnv at 'x-oz://boot/GetEnv'

prepare
    GetEnv = Boot_GetEnv.getenv

end

