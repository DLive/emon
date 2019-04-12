%%%-------------------------------------------------------------------
%%% @author xiaontao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. 4月 2019 16:37
%%%-------------------------------------------------------------------
-module(emon_vm_memory_collector).
-author("xiaontao").

-import(proplists, [get_value/2]).

%% API
-export([init/0, collect_vm_memory_info/0, format_to_string/1]).

init() ->
  reg_heart_hook(),
  ok.

reg_heart_hook() ->
  emon:hook_heartbeat(?MODULE, collect_vm_memory_info, 0).

collect_vm_memory_info() ->
  Data = erlang:memory(),
  MemoryInfo =
    lists:foldl(
      fun(Item, Acc)->
        case memory_info_format({Item, Data}) of
          skip-> Acc;
          {Key, Value} ->
            Acc#{Key => format_to_string(Value)}
        end
      end, #{}, metrics()),

  %%io:format("~p~n.", [MemoryInfo]),
  emon:heartbeat("VM Memory Info", MemoryInfo),
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
    bytes_total_system,
    bytes_total_processes,
    atom_bytes_total_used,
    atom_bytes_total_free,
    processes_bytes_total_used,
    processes_bytes_total_free,
    dets_tables,
    ets_tables,
    system_bytes_total_atom,
    system_bytes_total_binary,
    system_bytes_total_code,
    system_bytes_total_ets,
    system_bytes_total_other
  ].

memory_other(Data) ->
  get_value(system, Data)
    - get_value(atom, Data)
    - get_value(binary, Data)
    - get_value(code, Data)
    - get_value(ets, Data).

memory_info_format({bytes_total_system, Data}) ->
  {"Total Allocated Memory For System", get_value(system,  Data)};
memory_info_format({bytes_total_processes, Data}) ->
  {"Total Allocated Memory For Processes", get_value(processes, Data)};
memory_info_format({atom_bytes_total_used, Data}) ->
  {"Used Allocated Memory For Atoms", get_value(atom_used, Data)};
memory_info_format({atom_bytes_total_free, Data}) ->
  {"Free Allocated Memory For Atoms", get_value(atom, Data) - get_value(atom_used, Data)};
memory_info_format({processes_bytes_total_used, Data}) ->
  {"Used Allocated Memory For Processes", get_value(processes_used, Data)};
memory_info_format({processes_bytes_total_free, Data}) ->
  {"Free Allocated Memory For Processes", get_value(processes, Data) - get_value(processes_used, Data)};
memory_info_format({dets_tables, _Data}) ->
  {"VM DETS Table Count", length(dets:all())};
memory_info_format({ets_tables, _Data}) ->
  {"VM ETS Table Count", length(ets:all())};
memory_info_format({system_bytes_total_atom, Data}) ->
  {"Allocated System Memory For Atoms", get_value(atom, Data)};
memory_info_format({system_bytes_total_binary, Data}) ->
  {"Allocated System Memory For Binary", get_value(binary, Data)};
memory_info_format({system_bytes_total_code, Data}) ->
  {"Allocated System Memory For Code", get_value(code, Data)};
memory_info_format({system_bytes_total_ets, Data}) ->
  {"Allocated System Memory For ETS", get_value(ets, Data)};
memory_info_format({system_bytes_total_other, Data}) ->
  {"Allocated System Memory For Other", memory_other(Data)};
memory_info_format(_)->
  skip.
