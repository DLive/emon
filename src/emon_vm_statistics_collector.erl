%%%-------------------------------------------------------------------
%%% @author xiaontao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. 4月 2019 18:15
%%%-------------------------------------------------------------------
-module(emon_vm_statistics_collector).
-author("xiaontao").

%% API
-export([init/0, collect_vm_statistics_info/0]).

init() ->
  reg_heart_hook(),
  ok.

reg_heart_hook() ->
  emon:hook_heartbeat(?MODULE, collect_vm_statistics_info, 0).

collect_vm_statistics_info() ->
  StatisticsInfo =
    lists:foldl(
      fun(Item, Acc)->
        case statistics_info_format(Item) of
          skip-> Acc;
          {Key, Value} ->
            Acc#{Key => format_to_string(Value)}
        end
      end, #{}, metrics()),

  %%io:format("~p~n.", [StatisticsInfo]),
  emon:heartbeat("VM Statistics Info", StatisticsInfo),
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
  {{input, Input}, {output, Output}} = erlang:statistics(io),
  {ContextSwitches, _} = erlang:statistics(context_switches),
  [DirtyCPURunQueueLength, DirtyIORunQueueLength] = dirty_stat(),
  {NumberOfGCs, WordsReclaimed, _} = erlang:statistics(garbage_collection),
  WordSize = erlang:system_info(wordsize),
  {ReductionsTotal, _} = erlang:statistics(reductions),
  RunQueuesLength = erlang:statistics(run_queue),
  {Runtime, _} = erlang:statistics(runtime),
  {WallclockTime, _} = erlang:statistics(wall_clock),

  [
    {bytes_output_total, Output},
    {bytes_received_total, Input},
    {context_switches, ContextSwitches},
    {dirty_cpu_run_queue_length, DirtyCPURunQueueLength},
    {dirty_io_run_queue_length, DirtyIORunQueueLength},
    {garbage_collection_number_of_gcs, NumberOfGCs},
    {garbage_collection_bytes_reclaimed, WordsReclaimed * WordSize},
    {garbage_collection_words_reclaimed, WordsReclaimed},
    {reductions_total, ReductionsTotal},
    {run_queues_length_total, RunQueuesLength},
    {runtime_milliseconds, Runtime},
    {wallclock_time_milliseconds, WallclockTime}
  ].

-ifdef(recent_otp).
dirty_stat() ->
  try
    SO = erlang:system_info(schedulers_online),
    RQ = erlang:statistics(run_queue_lengths_all),
    case length(RQ) > SO of
      true -> lists:sublist(RQ, length(RQ) - 1, 2);
      false -> [undefined, undefined]
    end
  catch _:_ -> [undefined, undefined]
  end.
-else.
dirty_stat() ->
  [undefined, undefined].
-endif.

statistics_info_format({bytes_output_total, Value}) ->
  {"Output Bytes", Value};
statistics_info_format({bytes_received_total, Value}) ->
  {"Inout Bytes", Value};
statistics_info_format({context_switches, Value}) ->
  {"Context Switched", Value};
statistics_info_format({dirty_cpu_run_queue_length, Value}) ->
  {"Dirty CPU Run-Queue Length", Value};
statistics_info_format({dirty_io_run_queue_length, Value}) ->
  {"Dirty IO Run-Queue Length", Value};
statistics_info_format({garbage_collection_number_of_gcs, Value}) ->
  {"GC Amount", Value};
statistics_info_format({garbage_collection_bytes_reclaimed, Value}) ->
  {"GC Bytes Reclaimed", Value};
statistics_info_format({garbage_collection_words_reclaimed, Value}) ->
  {"GC Words Reclaimed", Value};
statistics_info_format({reductions_total, Value}) ->
  {"Total Reductions", Value};
statistics_info_format({run_queues_length_total, Value}) ->
  {"Run-Queue Length", Value};
statistics_info_format({runtime_milliseconds, Value}) ->
  {"Runtime For All Threads", Value};
statistics_info_format({wallclock_time_milliseconds, Value}) ->
  {"Wallclock Time", Value};
statistics_info_format(_)->
  skip.