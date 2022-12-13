```python
from functools import lru_cache

class Animal:

	@lru_cache
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

For this reason, it is generally not recommended to use @lru_cache in a class method. Instead, you can use it on a standalone function that is called by the class method, which will allow the results to be cached for all instances of the class.

Here is an example of how you could use @lru_cache on a standalone function that is called by a class method:

Copy code
from functools import lru_cache

class MyClass:
def my_method(self, arg1, arg2): # Call the standalone function and pass it the necessary arguments
result = my_standalone_function(arg1, arg2)
return result

@lru_cache()
def my_standalone_function(arg1, arg2): # Do some computation here and return the result
result = ...
return result
