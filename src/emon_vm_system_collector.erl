%%%-------------------------------------------------------------------
%%% @author xiaontao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. 4月 2019 14:58
%%%-------------------------------------------------------------------
-module(emon_vm_system_collector).
-author("xiaontao").

%% API
-export([init/0, collect_vm_system_info/0]).

init() ->
  reg_heart_hook(),
  ok.

reg_heart_hook() ->
  emon:hook_heartbeat(?MODULE, collect_vm_system_info, 0).

collect_vm_system_info() ->
  SystemInfo =
    lists:foldl(
      fun(Item, Acc)->
        try
          case erlang:system_info(Item) of
            unknown -> Acc;
            Value ->
              Result = format_to_string(Value),
              case system_info_format({Item, Result}) of
                skip-> Acc;
                {Key, Result} ->
                  Acc#{Key => Result}
              end
          end
        catch
          error:badarg -> Acc
        end
      end, #{}, metrics()),

  %%io:format("~p~n.", [SystemInfo]),
  emon:heartbeat("VM System Info", SystemInfo),
  ok.

format_to_string(Value) ->
  case is_integer(Value) of
    true ->
      integer_to_list(Value);
    false ->
      case Value == undefined of
        true ->
          "0";
        false ->
          Value
      end
  end.

metrics() ->
  [
    dirty_io_schedulers,
    dirty_cpu_schedulers,
    dirty_cpu_schedulers_online,
    ets_limit,
    logical_processors,
    logical_processors_available,
    logical_processors_online,
    port_count,
    port_limit,
    process_count,
    process_limit,
    schedulers,
    schedulers_online,
    %%smp_support,
    %%threads,
    thread_pool_size,
    %%time_correction,
    atom_count,
    atom_limit,
    allocators
  ].

system_info_format({dirty_io_schedulers, Value}) ->
  {"Dirty IO Schedulers", Value};
system_info_format({dirty_cpu_schedulers, Value}) ->
  {"Dirty CPU Schedulers", Value};
system_info_format({dirty_cpu_schedulers_online, Value}) ->
  {"Online Dirty CPU Schedulers", Value};
system_info_format({ets_limit, Value}) ->
  {"ETS Limit", Value};
system_info_format({logical_processors, Value}) ->
  {"Logical Processors", Value};
system_info_format({logical_processors_available, Value}) ->
  {"Available Logical Processors", Value};
system_info_format({logical_processors_online, Value}) ->
  {"Online Logical Processors", Value};
system_info_format({port_count, Value}) ->
  {"Port Count Of Local Node", Value};
system_info_format({port_limit, Value}) ->
  {"Port Limit Of Local Node", Value};
system_info_format({process_count, Value}) ->
  {"Processes Count", Value};
system_info_format({process_limit, Value}) ->
  {"Processes Limit", Value};
system_info_format({schedulers, Value}) ->
  {"Scheduler Threads Count", Value};
system_info_format({schedulers_online, Value}) ->
  {"Online Scheduler Threads Count", Value};
system_info_format({thread_pool_size, Value}) ->
  {"Async Threads Count", Value};
system_info_format({atom_count, Value}) ->
  {"Atom Count Of Local Node", Value};
system_info_format({atom_limit, Value}) ->
  {"Atom Limit Of Local Node", Value};
system_info_format({allocators, Value}) ->
  {"Allocators", Value};
system_info_format(_)->
  skip.