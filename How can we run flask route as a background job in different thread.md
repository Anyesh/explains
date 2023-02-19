## You can implement something like this

```python
import threading
import uuid
from functools import partial, wraps

from flask import abort, current_app, request
from werkzeug.exceptions import HTTPException, InternalServerError


tasks_repo: dict = {}


def run_async_task(f):
    """
        This decorator transforms a sync route to asynchronous by running it in a background thread.
    """

    @wraps(f)
    def wrapped(*args, **kwargs):
        def task(app, environ):
            # Create a request context similar to that of the original request
            with app.request_context(environ):
                try:
                    kwargs["task_id"] = task_id
                    tasks_repo[task_id]["result"] = f(*args, **kwargs)
                except HTTPException as e:
                    tasks_repo[task_id]["result"] = current_app.handle_http_exception(e)
                except Exception as e:
                    # The function raised an exception, so we set a 500 error
                    tasks_repo[task_id]["result"] = InternalServerError()
                    if current_app.debug:
                        # We want to find out if something happened so reraise
                        raise

        # Assign an id to the asynchronous task
        task_id = uuid.uuid4().hex

        # Record the task, and then launch it
        tasks_repo[task_id] = {
            "task": threading.Thread(
                target=task, args=(current_app._get_current_object(), request.environ),
            )
        }
        tasks_repo[task_id]["task"].start()
        tasks_repo[task_id]["task"].join()

        # Return a 202 response, with an id that the client can use to obtain task status
        return {"task_id": task_id}, 202

    return wrapped
```
