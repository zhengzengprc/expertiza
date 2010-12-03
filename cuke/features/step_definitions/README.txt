Every file in this directory is run once before executing any test no matter which feature you are running. 

Therefore:

Do not load a file more than once, you will duplicate method and variable errors.

Do not define methods with the same name.