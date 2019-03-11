%%%-------------------------------------------------------------------
%%% @author dlive
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Mar 2019 11:03 AM
%%%-------------------------------------------------------------------
-module(emon_transaction).
-author("dlive").

%% API
-export([new_with_duration/3]).


new_with_duration(Type, Name, Duration)->
    case enable() of
        true->
            erlcat:log_transaction_with_duration(Type,Name,Duration),
            ok;
        _ ->
            fail
    end.
