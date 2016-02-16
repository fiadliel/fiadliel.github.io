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

This is enough to get a service running. The next step will be to parse HTTP requests, in particular,
query and path parameters.
