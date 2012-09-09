functor

import
    System(show:Show)
    OS(getEnv:OSGetEnv)
    GetEnv at 'x-oz://boot/GetEnv.ozf'

define
    {Show 'Hello, '#{GetEnv.getenv 'USER'}}
    {Show 'Hello, '#{OSGetEnv 'USER'}}
    {Show 'You are using '#{GetEnv.getenv 'SHELL'}}
    {Show 'You are using '#{OSGetEnv 'SHELL'}}
    {Show 'This should be unit: '#{GetEnv.getenv 'dksdhfksdf'}}
    {Show 'This should be unit: '#{OSGetEnv 'dksdhfksdf'}}
    %{Show 'Hello'}
end

