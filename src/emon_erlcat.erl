%%%-------------------------------------------------------------------
%%% @author dlive
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Apr 2019 5:20 PM
%%%-------------------------------------------------------------------
-module(emon_erlcat).
-author("dlive").

-include("emon.hrl").
%% API
-export([get_context/0,reset_msgtree_info/1,get_msgtree_info/0]).

get_context()->
    case get(?PROCESS_CONTEXT_FLAG) of
        undefined ->
            Context = erlcat:new_context(),
            put(?PROCESS_CONTEXT_FLAG, Context),
            Context;
        Value ->
            Value
    end.

reset_msgtree_info(MessageTreeInfo)->
    put(?PROCESS_CONTEXT_MSG_TREE,MessageTreeInfo).

get_msgtree_info()->
    get(?PROCESS_CONTEXT_MSG_TREE).
