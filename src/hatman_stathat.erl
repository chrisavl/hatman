-module(hatman_stathat).
%%
%% This module is mostly based on the Erlang code in:
%% https://github.com/stathat/shlibs
%%

%% API
-export([ez_json/1, ez_json/2]).

%% Exported for testing with:
%%      hatman_stathat:ez_json(hatman_stathat:sample_stats()).
-export([sample_stats/0]).

-define(EZ_API_URL, "http://api.stathat.com/ez").

%%
%% API
%%

ez_json(Stats) ->
    ez_json(ez_key(), Stats).

ez_json(EzKey, Stats) ->
    Ejson = {[{ezkey, ensure_binary(EzKey)},
              {data, lists:map(fun (Stat) -> {Stat} end, Stats)}]},
    post(?EZ_API_URL, jiffy:encode(Ejson)).


%%
%% INTERNAL
%%

ez_key() ->
    {ok, EzKey} = application:get_env(hatman, ez_key),
    EzKey.


ensure_binary(B) when is_binary(B) -> B;
ensure_binary(L) when is_list(L)   -> list_to_binary(L).


post(Url, Body) ->
    lhttpc:request(Url, post, [{"Content-Type", "application/json"}], Body, 5000).


sample_stats() ->
    [[{stat, <<"page view">>}, {count, 2}],
     [{stat, <<"messages sent~total,female,europe">>}, {count, 1}],
     [{stat, <<"request time~total,messages">>}, {value, 23.094}],
     [{stat, <<"ws0: load average">>}, {value, 0.732}, {t, 1363118126}]
    ].
