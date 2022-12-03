``` python
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