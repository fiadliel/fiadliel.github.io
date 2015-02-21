---
title: Process Tutorial
---

Process is a ...

Some useful imports to start would be:
```scala
scala> import scalaz.stream._
import scalaz.stream._
```

Here is an example of a process that continuously emits 1:

```scala
scala> Process.emit(1)
res0: scalaz.stream.Process0[Int] = Emit(Vector(1))
```

```scala
scala> val emit1 = Process.emit(1)
emit1: scalaz.stream.Process0[Int] = Emit(Vector(1))

scala> emit1 ++ emit1
res1: scalaz.stream.Process[Nothing,Int] = Append(Emit(Vector(1)),Vector(<function1>))
```

Let's try and compile this into a runnable task:

```scala
scala> Process.emit(1).liftIO.run
res2: scalaz.concurrent.Task[Unit] = scalaz.concurrent.Task@171f331f
```

Note that `.run` returns a `Task[Unit]`, it will not provide
any values from the process. That means that if you wish to do
something with the values, some side-effects need to be
performed within the process chain.
