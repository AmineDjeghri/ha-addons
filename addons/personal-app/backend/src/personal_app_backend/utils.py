import ast
import timeit
from personal_app_backend.backend_settings import logger


def safe_eval(x):
    try:
        return ast.literal_eval(x)
    except:
        return []


def time_function(func):
    def wrapper(*args, **kwargs):
        start_time = timeit.default_timer()
        result = func(*args, **kwargs)

        end_time = timeit.default_timer()
        execution_time = round(end_time - start_time, 2)

        logger.debug(f"Function {func.__name__} took {execution_time} seconds to execute.")

        return result

    return wrapper
