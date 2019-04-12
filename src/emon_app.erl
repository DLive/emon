%%%-------------------------------------------------------------------
%% @doc emon public API
%% @end
%%%-------------------------------------------------------------------

-module(emon_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    Ret = emon_sup:start_link(),
    %% Init Collectors
    emon_vm_memory_collector:init(),
    emon_vm_statistics_collector:init(),
    emon_vm_system_collector:init(),
    Ret.

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
