-module(emon).

-include_lib("erlcat/include/erlcat.hrl").
-include("emon.hrl").
-export([init/1,destroy/0,enable/0,hook_heartbeat/3]).
-export([event/4, error/2, metric_count/2, metric_duration/2, metric_sum/2]).
-export([heartbeat/1]).

init(Appkey)->
    case enable() of
        true->
            Encode = application:get_env(emon,erlcat_encode,0),
            Debug = application:get_env(emon,erlcat_debug,0),
            erlcat:init_cat(Appkey,#cat_config{enable_debugLog = Debug,enable_heartbeat = 0,encoder_type = Encode}),
            ok;
        _ ->
            fail
    end.

destroy()->
    case enable() of
        true->
            erlcat:cat_client_destroy(),
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

heartbeat(HeartMap)->
    case application:get_env(emon,enable,true) of
        true->
            erlcat:log_heartbeat(HeartMap),
            ok;
        _ ->
            fail
    end.

hook_heartbeat(Module,Fun,Arity)->
    hooks:reg(?HOOK_EVENT_HEARTBEAT, Module, Fun, Arity).
