# Stathat + Statman

This library pushes your metrics collected with
[statman](https://github.com/knutin/statman) to [stathat](http://www.stathat.com).

Statman metrics maps to stathat data points in the following way:

 * histogram -> value
 * counter   -> count
 * gauge     -> value

Statman keys are flattened and join with a "/", e.g {my, key} to "my/key".

Pretty much a carbon copy of [newrelic-erlang](https://github.com/wooga/newrelic-erlang).

## Configuration

Your stathat `ez_key` needs to be set as an application
environment variable for the `hatman` app.

You may also explicitly whitelist stats by setting the `whitelist`
application environment variable for the `hatman` app. If the whitelist
is `undefined` all metrics are sent to stathat.

So an example config would be something like this (whitelist is optional, if
undefined it means all statman keys are considered whitelisted):

    > application:get_env(hatman, ez_key).
    {ok, "stathat@example.org"}.
    > application:get_env(hatman, whitelist).
    {ok, [{db, write_latency}, {db, read_latency}, <<"some_other_statman_key">>]}.


To get started and configuring which polling function to use, do this:

    application:set_env(hatman, ez_key, "stathat@example.org").
    application:start(hatman).
    statman_aggregator:start_link().
    hatman_poller:start_link(fun hatman_statman:poll/1).

To test that hatman works, do this:

    application:start(hatman).
    EzKey = "stathat@example.org".
    hatman_stathat:ez_json(EzKey, hatman_stathat:sample_stats()).


## Extending hatman

I only need it for statman but if you get your metrics from some other tool it
should be fairly easy to plug in your on poll function which formats your data
for stathat. Check out how formating is done in `hatman_statman.erl`.
