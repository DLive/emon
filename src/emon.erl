-module(emon).

-include_lib("erlcat/include/erlcat.hrl").

-export([init/1,enable/0]).

-export([event/4, error/2, metric_count/2, metric_duration/2, metric_sum/2]).



init(Appkey)->
    case enable() of
        true->
            erlcat:init_cat(Appkey,#cat_config{enable_debugLog = 1,enable_heartbeat = 1}),
            ok;
        _ ->
            fail
    end.


event(Type, Name, Status, Data)->
    case enable() of
        true->
            erlcat:log_event(Type,Name,Status,Data),
            ok;
        _ ->
            fail
    end.
error(Message, ErrStr) ->
    case enable() of
        true->
            erlcat:log_error(Message,ErrStr),
            ok;
        _ ->
            fail
    end.

metric_count(Name, Count) ->
    case enable() of
        true->
            erlcat:log_metric_for_count(Name,Count),
            ok;
        _ ->
            fail
    end.

metric_duration(Name, Count) ->
    case enable() of
        true->
            erlcat:log_metric_for_duration(Name,Count),
            ok;
        _ ->
            fail
    end.

metric_sum(Name, Count)->
    case enable() of
        true->
            erlcat:log_metric_for_sum(Name,Count),
            ok;
        _ ->
            fail
    end.



enable()->
    case application:get_env(emon,enable,true) of
        true->
            true;
        _ ->
            false
    end.