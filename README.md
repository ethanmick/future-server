# Future Server

# In Development #
This won't work yet.


Future is a simple to setup, scaleable, independent, memory clean, future job scheduler. It solve sthe problem of:

### "I want this code to run in 20 minutes."

Oh, that's easy, just use `setTimeout`!

```js
setTimeout(function() {
	someCode(parameters)
}, 1200000);
```

No problem! Except... [maybe](https://github.com/joyent/node/issues/4273) [these](https://github.com/joyent/node/issues/1007). And what if you don't want to run **one** thing in 20 minutes, but rather hundreds of things? What if you have thousands of future events going on? Worse, what happens when the server crashes? All the *jobs* in memory will die, and you will have no record of what was happening.

#### Future is separate
Future is designed to be in it's own process. It is run as a different command than your application, and works similarly to an HTTP server, scheduling and firing off jobs. Node does really well as an HTTP server, and Future is designed to work in the same way, with minimal overhead.

#### Future is Persistent
Future saves all jobs in it's own database. If Future crashes, all jobs will be saved and immedietely set to work when it comes back up. Since Future is separate from your application, if your application can no longer reach future (and it's critical it can), the Future client can also crash your application so people cannot do malicious things.

#### Future is scalable
Future can be setup to use additional CPU and TCP connections to ensure jobs are executed in realtime (well, pretty close. I need it to be accurate to less than 1 second). Future will test the latency between the client and server and send jobs *ahead* of time to ensure the client gets them at the correct time.

