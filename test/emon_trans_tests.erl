%%%-------------------------------------------------------------------
%%% @author dlive
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Apr 2019 11:16 AM
%%%-------------------------------------------------------------------
-module(emon_trans_tests).
-author("dlive").

-include_lib("eunit/include/eunit.hrl").

-export([init/1]).

simple_test() ->
    ?assert(true).


setup() ->
    emon:init("testapp"),
    ok.

remote_call_test()->
    setup(),
    Pid=spawn(node(),emon_trans_tests,init,[p1]),
    spawn(node(),emon_trans_tests,init,[p2]),
    spawn(node(),emon_trans_tests,init,[p3]),
    erlang:send(Pid,{request1}),
    timer:sleep(5000),
    ok.

init(Name)->
    io:format(user,"stat process ~p ~p~n",[Name,self()]),
    register(Name,self()),
    loop().
loop()->
    receive
        {request1} ->
            emon_trans:remote_call_client(),
            T1 = emon_trans:new("EMON_MSG.unit", "send1"),
            sleep1(),
            emon_trans:complete(T1),
            io:format(user,"ttttttt1~n",[]),

            erlang:send(whereis(p2),{request2,emon_trans:get_msgtree_info()}),
            ok;
        {request2,Context}->
            emon_trans:remote_call_server(Context),
            T2 = emon_trans:new( "EMON_MSG.unit", "send2"),
            sleep1(),
            emon_trans:complete(T2),
            io:format(user,"ttttttt2~n",[]),
            erlang:send(whereis(p3),{request3,emon_trans:get_msgtree_info()}),
            ok;
        {request3,Context}->
            emon_trans:remote_call_server(Context),
            T3 = emon_trans:new( "EMON_MSG.unit", "send3"),
            sleep1(),
            io:format(user,"ttttttt3~n",[]),
            emon_trans:complete(T3),
            ok;
        Unkonw->
            io:format(user,"uknow ~p ~n",[Unkonw]),
            ok
    after 1000->
        ok
    end,
    loop().


sleep1() ->

    timer:sleep(rand:uniform(200)).