# What is GIL?

(GIL prevents multiple native threads from executing Python bytecodes at once)

The Global Interpreter Lock (GIL) is a mechanism used in the CPython implementation of the Python programming language to ensure that only one thread executes Python bytecode at a time. This is done to prevent conflicts between multiple threads accessing and modifying Python objects in memory. While this mechanism prevents conflicts, it also means that Python programs cannot fully take advantage of multiple processors or cores on a system, which can lead to performance issues for certain types of programs.

# what happens to GIL when using threading in python?

When using the threading module for parallel execution, only one Python thread can execute Python bytecodes at a time, and the others will be blocked.

However, this limitation does not apply to I/O bound tasks, because I/O operations are typically performed by the operating system outside of the Python interpreter. This means that while one Python thread is blocked waiting for an I/O operation to complete, another Python thread can still be running and executing Python bytecodes.

For example, if you are doing a task of reading files from disk, and you want to read multiple files simultaneously, you can create multiple threads and assign each thread to read one file. While one thread is waiting for the file to be read from disk, the GIL is released and other thread can execute and read another file. This way, the program can finish reading all files faster, than if it was reading one file after another in a single thread.

It's worth noting that using the concurrent.futures library with ThreadPoolExecutor will also work in the same way, in this case, the parallelism is achieved by using the threading module internally and the GIL will not be a bottleneck for I/O bound tasks.

In practice, the GIL can limit the performance benefits of using multiple threads in a Python program, especially if the program spends a lot of time executing CPU-bound operations in pure Python code. To work around this limitation, you can use processes instead of threads, as each process has its own interpreter and GIL. Alternatively, you can use libraries that release the GIL during CPU-bound operations, such as NumPy or Cython, or use asynchronous programming techniques such as asyncio to achieve concurrency without using threads.
