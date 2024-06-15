```python
raise EXCEPTION from CAUSE
```

When we use `from` while raising an exception, the _`__cause__` attribute_ is set which means that the exception was _directly caused by_ `CAUSE`. If we don't use `from` then no `__cause__` is set, but we'll have the _`__context__` attribute_ and the traceback shows the context as _during handling something else happened_.

`__context__` is set when we use `raise` in an exception handler.

If a `__cause__` is set, a `__suppress_context__ = True` flag is also set on the exception; when `__suppress_context__` is set to `True`, the `__context__` is ignored when printing a traceback.

When raising from a exception handler where you _don't_ want to show the context (don't want a _during handling another exception happened_ message), then use `raise ... from None` to set `__suppress_context__` to `True`.

In other words, Python sets a _context_ on exceptions so you can introspect where an exception was raised, letting you see if another exception was replaced by it. You can also add a _cause_ to an exception, making the traceback explicit about the other exception (use different wording), and the context is ignored (but can still be introspected when debugging). Using `raise ... from None` lets you suppress the context being printed.

Here is the full example:

```python
In [1]: try:
   ...:     raise NotImplementedError("hahaha")
   ...:
   ...: except Exception as e:
   ...:     print(f"There was an error: {e}")
   ...:
There was an error: hahaha

In [2]: try:
   ...:     raise NotImplementedError("hahaha")
   ...:
   ...: except Exception as e:
   ...:     print(f"There was an error: {e!r}")
   ...:
There was an error: NotImplementedError('hahaha')

In [3]: try:
   ...:     raise NotImplementedError("hahaha")
   ...:
   ...: except Exception as e:
   ...:     print(f"There was an error: {e!r}")
   ...:     raise Exception("Oh No")
   ...:
There was an error: NotImplementedError('hahaha')
---------------------------------------------------------------------------
NotImplementedError                       Traceback (most recent call last)
Cell In[3], line 2
      1 try:
----> 2     raise NotImplementedError("hahaha")
      4 except Exception as e:

NotImplementedError: hahaha

During handling of the above exception, another exception occurred:

Exception                                 Traceback (most recent call last)
Cell In[3], line 6
      4 except Exception as e:
      5     print(f"There was an error: {e!r}")
----> 6     raise Exception("Oh No")

Exception: Oh No

In [4]: try:
   ...:     raise NotImplementedError("hahaha")
   ...:
   ...: except Exception as e:
   ...:     print(f"There was an error: {e!r}")
   ...:     raise Exception("Oh No") from e
   ...:
There was an error: NotImplementedError('hahaha')
---------------------------------------------------------------------------
NotImplementedError                       Traceback (most recent call last)
Cell In[4], line 2
      1 try:
----> 2     raise NotImplementedError("hahaha")
      4 except Exception as e:

NotImplementedError: hahaha

The above exception was the direct cause of the following exception:

Exception                                 Traceback (most recent call last)
Cell In[4], line 6
      4 except Exception as e:
      5     print(f"There was an error: {e!r}")
----> 6     raise Exception("Oh No") from e

Exception: Oh No
```

It's all about message. If exception is raised from e then we will have `The above exception was the direct cause of the following exception:`
Else we have `During handling of the above exception, another exception occurred:`. First one is clear and explicit.
