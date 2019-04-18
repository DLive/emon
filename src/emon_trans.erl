%%%-------------------------------------------------------------------
%%% @author dlive
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Apr 2019 5:54 PM
%%%-------------------------------------------------------------------
-module(emon_trans).
-author("dlive").

%% API
-export([]).

-export([new/2, set_status/2, set_timestamp/2, set_duration/2, set_duration_start/2, add_data/2, add_kv/3, complete/1,remote_call_client/0,remote_call_server/1,get_msgtree_info/0]).

new(Name,Type) ->
    erlcat:new_transaction(emon_erlcat:get_context(),Name,Type).

set_status(CatTransaction,State)->
    erlcat:set_status(emon_erlcat:get_context(),CatTransaction,State).

set_timestamp(CatTransaction,Timestamp)->
    erlcat:set_timestamp(emon_erlcat:get_context(),CatTransaction,Timestamp).

set_duration(CatTransaction, Duration)->
    erlcat:set_duration(emon_erlcat:get_context(),CatTransaction,Duration).

set_duration_start(CatTransaction, DurationStart)->
    erlcat:set_duration_start(emon_erlcat:get_context(),CatTransaction,DurationStart).

add_data(CatTransaction, Data)->
    erlcat:add_data(emon_erlcat:get_context(),CatTransaction,Data).

add_kv(CatTransaction, Key, Value)->
    erlcat:add_kv(emon_erlcat:get_context(),CatTransaction,Key,Value).

complete(CatTransaction)->
    erlcat:complete(emon_erlcat:get_context(),CatTransaction).


remote_call_client()->
    MessageThreeInfo = erlcat:log_remote_call_client(emon_erlcat:get_context()),
    emon_erlcat:reset_msgtree_info(MessageThreeInfo),
    MessageThreeInfo.
remote_call_server({RootId,ParentId,ChildId}) ->
    MessageThreeInfo = erlcat:log_remote_call_server(emon_erlcat:get_context(),RootId,ParentId,ChildId),
    emon_erlcat:reset_msgtree_info(MessageThreeInfo),
    ok;
remote_call_server(_) ->
    ok.

get_msgtree_info()->
    emon_erlcat:get_msgtree_info().