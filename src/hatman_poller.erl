-module(hatman_poller).
-behaviour(gen_server).

%% API
-export([start_link/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-record(state, {poll_fun}).

%%
%% API
%%

start_link(PollF) ->
    gen_server:start_link(?MODULE, [PollF], []).

%%
%% gen_server callbacks
%%

init([PollF]) ->
    self() ! poll,
    {ok, #state{poll_fun = PollF}}.

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(poll, State) ->
    erlang:send_after(60000, self(), poll),

    case catch (State#state.poll_fun)() of
        {'EXIT', Error} ->
            error_logger:warning_msg("~s: polling failed: ~p~n", [?MODULE, Error]),
            ok;
        Stats ->
            case catch hatman_stathat:ez_json(Stats) of
                ok ->
                    ok;
                Other ->
                    error_logger:warning_msg("~p: push failed: ~p~n",
                                             [?MODULE, Other]),
                    ok
            end
    end,

    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
