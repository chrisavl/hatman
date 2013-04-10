# Statman + Stathat

This library pushes your metrics collected with
[statman](https://github.com/knutin/statman) to [stathat](http://www.stathat.com).

Statman metrics maps to stathat data points in the following way:

 * histogram -> value
 * counter   -> count
 * gauge     -> value

Statman keys are flattened and join with a space, e.g {my, key} to "my key".

## Configuration

Your stathat `ez_key` needs to be set as an application
environment variable for the `hatman` app.
