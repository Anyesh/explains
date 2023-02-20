# Be careful while using @lru_cache on method

```python
from functools import lru_cache

class Animal:

	@lru_cache(max_size=None)
	def get_list(self):
		print("Running .. .")
		return ["Dog", "Cat", "Cow"]


>>> Animal().get_list()
running
['Dog', 'Cat', 'Cow']
>>> Animal().get_list()
running
['Dog', 'Cat', 'Cow']
>>> Animal().get_list()
running
['Dog', 'Cat', 'Cow']
>>> Animal().get_list()
running
['Dog', 'Cat', 'Cow']
>>> Animal().get_list()
running
['Dog', 'Cat', 'Cow']


func.__wrapped__
func.cache_info()
func.cachec_clear()
```

@lru_cache is a decorator for caching the results of a function. It can be used to improve the performance of a function by storing its results so that they can be looked up quickly the next time the function is called with the same arguments.

However, when @lru_cache is used in a class method, it can cause problems because it will only store the results of the method for a single instance of the class. This means that if the method is called on a different instance of the class, the results will not be cached and the method will have to be recomputed, which can be inefficient.

```python
>>> a = Animal()
>>> a.get_list()
running
['Dog', 'Cat', 'Cow']
>>> a.get_list()
['Dog', 'Cat', 'Cow']
```

Even if we do this, this will create an instance that lives in the memory and will not be garbage collected until the process ends (or evicted from the cache... but we have max_size of None so it will clear on process end only).

Why this happens?

> The decorator creates an assignment inside a class body. Any assignment inside a class body is basically a global. It is not bound to the class instance, but to the class itself.

For this reason, it is generally not recommended to use @lru_cache in a class method. Instead, you can use it on a standalone function that is called by the class method, which will allow the results to be cached for all instances of the class.

```python
from functools import lru_cache

class Animal:

	def __init__(self):
		self.get_list = lru_cache(max_size=None)(self._get_list)

	def get_list(self):
		print("Running .. .")
		return ["Dog", "Cat", "Cow"]


>>> a = Animal()
>>> a.get_list()
running
['Dog', 'Cat', 'Cow']
>>> a.get_list()
['Dog', 'Cat', 'Cow']

```

Some helpful attributes and methods of @lru_cache

```python
>>> a.get_list.__wrapped__
<bound method Animal._get_list of <__main__.Animal object at 0x7f9b8c0f9a90>>
>>> a.get_list.cache_info()
CacheInfo(hits=1, misses=1, maxsize=None, currsize=1)
>>> a.get_list.cache_clear()
>>> a.get_list.cache_info()
CacheInfo(hits=0, misses=0, maxsize=None, currsize=0)
```
