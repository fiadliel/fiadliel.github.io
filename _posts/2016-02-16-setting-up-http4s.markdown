---
layout: post
title:  "Setting up a http4s skeleton project"
categories: http4s
---
Setting up a http4s project is fairly simple.

Set up a `build.sbt` like this:

{% highlight scala %}
val http4sVersion = "0.12.1"

libraryDependencies += "org.http4s" %% "http4s-dsl"          % http4sVersion  // to use the core dsl
libraryDependencies += "org.http4s" %% "http4s-blaze-server" % http4sVersion  // to use the blaze backend
{% endhighlight %}

Then a basic skeleton for serving can look like:

{% highlight scala %}
import org.http4s._
import org.http4s.dsl._
import org.http4s.server.blaze.BlazeBuilder

object SkeletonService {
  val service = HttpService {
    case GET -> Root =>
      Ok("hello world")
  }
}

object SkeletonServer extends App {
  BlazeBuilder.bindHttp(8080)
    .mountService(SkeletonService.service, "/")
    .run
    .awaitShutdown()
}
{% endhighlight %}

`BlazeBuilder` is an object which provides a builder pattern for setting up a running
server which uses the Blaze (async IO) backend.

The code in `SkeletonServer` binds to all interfaces on port 8080, sets up a service at the
path `/`, starts the server, and waits until the server loop terminates.

When defining your service, `HttpService` expects a partial function from `Request` to
`Task[Response]`. That is, given a pattern match on the left-hand-side (which we will generally
write using the http4s DSL), the right-hand-side will return a `scalaz.concurrent.Task`, which,
when run, will return the response. In general, the framework will be responsible for running
that `Task`.

The above code is enough to get a service running. The next step will be to
parse HTTP requests, in particular, query and path parameters.
