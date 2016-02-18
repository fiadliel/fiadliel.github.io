---
layout: post
title:  "HttpRequest and pattern matching on requests"
categories: http4s
---

## HttpRequest

`org.http4s.HttpRequest` is the type that represents the handler for your web
service. It takes a `Request`, and returns a `Task[Response]`, which when run,
provides the response (HTTP response code, headers, body, etc.).

> If you paid attention in scalaz class (but who ever does that?), the signature
`Request => Task[Response]` looks very like something that could be represented
by a `Kleisli[Task, Request, Response]`. And indeed, this is the underlying
type.

The [HttpRequest API](http://http4s.org/api/0.12/#org.http4s.HttpService$)
offers some useful constructor helpers. A common pattern is to define a partial
function; patterns that do not match get a fallback response instead. The
default fallback response is _404 Not Found_, which can be changed.

When defining a partial function, your code will look something like this:
{% highlight scala %}
import org.http4s._

val service = HttpService {
  case *PATTERN1* => { /* generate response */ }
  case *PATTERN2* => { /* generate response */ }
  ...
}
{% endhighlight %}

It is possible to lift a pure function, in which case you have full control
over the mapping without being limited by the available pattern matchers.

## Request pattern matching

http4s offers a DSL for creating patterns that match various kinds of HTTP
requests. First, we need to extract the HTTP method, and the path. The
operator which does this is `->` in the `org.http4s.dsl` package.

So we can, without doing any further filtering, pull out the method and
path like this:
{% highlight scala %}
import org.http4s._
import org.http4s.dsl._

val service = HttpService {
  case method -> path => { /* generate response */ }
}
{% endhighlight %}

Here, `method` will be of type `Method`, and `path` will be of type `Path`.
Just pulling out the request and path like this is interesting, but we will
usually want to explicitly match both on the method, and on particular path
patterns.

### Matching HTTP methods

We can match on individual methods, combinations of methods, or on any
methods in a particular case statement.

We have already seen the case above where no method is specified, but the
request's method is set as the value of the supplied binding.

If we want to match a single method, the code will look like this:
{% highlight scala %}
import org.http4s._
import org.http4s.dsl._

val service = HttpService {
  case GET -> path => { /* generate response */ }
}
{% endhighlight %}

The above code matches only GET requests; other types of methods are not
matched by the partial function, and fall through to the default response.

If we want to match multiple methods, this can be done using
`|`:
{% highlight scala %}
import org.http4s._
import org.http4s.dsl._

val service = HttpService {
  case (GET | PUT) -> path => { /* generate response */ }
}
{% endhighlight %}

Here, we match requests with either method type GET or PUT.

As these are standard pattern matchers, we can use all the usual
syntax, so we can also capture the exact method while matching
against multiple methods:
{% highlight scala %}
import org.http4s._
import org.http4s.dsl._

val service = HttpService {
  case (method@(GET | PUT)) -> path => { /* generate response */ }
}
{% endhighlight %}

### Matching HTTP paths

#### Splitting HTTP path by slashes from `Root` operator

*Use this when there is a known number of slashes in the path. This matching
style cannot match an arbitrary number of slashes in a path.*

Paths are matched from left to right. The first matcher *must* be
`Root`, which represents the initial root of the path. Successive
parts of the path are then matched using the `/` matcher, which
matches the next part of the path, but not including a '/' character.

{% highlight scala %}
import org.http4s._
import org.http4s.dsl._

val service = HttpService {
  case GET -> Root / path =>
    { /* path must not contain '/' to match */ }

  case GET -> Root / path1 / path2 =>
    { /* path has two parts, separated by '/' */ }

  case GET -> Root / "about" / path2 =>
    { /* path begins with "/about", has one more part */ }
}
{% endhighlight %}


#### Splitting HTTP path by `/:` operator

*Use this when the total number of slashes is unknown. It matches any number of
slashes.*

Paths can be matched instead using the `/:` matching operator, which binds to
the right instead of left. When this is used, it separates all parts of the
path by slashes, until it runs out of matchers. The rightmost part of the path
is greedy, and grabs any remaining parts.

{% highlight scala %}
import org.http4s._
import org.http4s.dsl._

val service = HttpService {
  case GET -> "a" /: "b" /: rest => { /* generate response */ }
}
{% endhighlight %}

The above code matches a path starting with `/a/b`, and the `rest` variable
then contains any remaining part of the path.

Note also that the `Root` matcher is not used for this matching style.

### Extracting & validating non-string types

#### Integers

`IntVar(i)` will match part of the path as if it were an Integer, and if it is,
will bind the resulting value into i.

{% highlight scala %}
import org.http4s._
import org.http4s.dsl._

val service = HttpService {
  case GET -> Root / user / IntVar(id) =>
    { /* id variable is an Int, doesn't match otherwise */ }
}
{% endhighlight %}

#### Longs

`LongVar(i)` does the same job as `IntVar(i)`, but matches Long values.

#### Matching file extensions

`~` is the file extension matcher. The string will be split into two, where
the split happens at the last occurrence of a `.` character.

e.g. `name ~ "json"` will match a file with the extension `.json`.

#### Custom extractors

As http4s is using all the normal pattern matching machinery, custom extractors
can be written by anybody, just by implementing an object with an `unapply`
method of the appropriate type. For example, one might write a UUID extractor
like this:
{% highlight scala %}
import java.util.UUID

object UUID {
  def unapply(s: String): Option[UUID] = {
    try {
      Some(UUID.fromString(s))
    } catch {
      case ex: IllegalArgumentException => None
    }
  }
}
{% endhighlight %}

### TODO: Query parameters
