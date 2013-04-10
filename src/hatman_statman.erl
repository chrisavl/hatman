-module(hatman_statman).

-export([poll/1]).

poll(Whitelist) ->
    {ok, Metrics} = statman_aggregator:get_window(60),

    lists:flatmap(fun format_metric/1,
                  lists:filter(fun (Metric) ->
                                       is_whitelisted(Metric, Whitelist)
                               end, Metrics)).


is_whitelisted(_Metric, undefined) ->
    true;
is_whitelisted(Metric, Whitelist) ->
    lists:member(proplists:get_value(type, Metric), Whitelist).


format_metric(Metric) ->
    case proplists:get_value(type, Metric) of
        histogram -> format_histogram(Metric);
        counter   -> format_counter(Metric);
        gauge     -> format_gauge(Metric);
        _         -> []
    end.

format_histogram(Metric) ->
    lists:map(fun (Sample) ->
                      [{stat, format_key(proplists:get_value(key, Metric))}, {value, Sample}]
              end, proplists:get_value(value, Metric, [])).

format_counter(Metric) ->
    [[{stat, format_key(proplists:get_value(key, Metric))},
      {count, proplists:get_value(value, Metric)}]].

format_gauge(Metric) ->
    [[{stat, format_key(proplists:get_value(key, Metric))},
      {value, proplists:get_value(value, Metric)}]].


format_key(Key) ->
    iolist_to_binary(format_key2(Key)).

format_key2(Key) when is_tuple(Key) ->
    lists:map(fun format_key2/1, tuple_to_list(Key));
format_key2(Key) when is_atom(Key) ->
    [atom_to_list(Key)];
format_key2(Key) when is_binary(Key) orelse is_list(Key) ->
    [Key].
