# mpp, a mini preprocessor

This mini preprocessor parses files and resolves `#include` and `#define` macros
similar to how [`cpp(1)`](http://linux.die.net/man/1/cpp) does.

## Get it

Download the latest stable binary from our [Releases
page](https://github.com/foca/mpp/releases/latest).

If you want the bleeding edge:

``` sh
$ git clone https://github.com/foca/mpp && cd mpp
$ ./configure --prefix=/usr/local
$ make
$ make install
```

## Example

Given the following two CSS files:

``` css
/* app.css */

#include "other.css"

#define $margin 15px

.something-other {
  margin: $margin;
}
```

``` css
/* other.css */

.something {
  padding: 0;
}
```

Running `mpp app.css` will result in this:

``` css
.something {
  padding: 0;
}



.something-other {
  margin: 15px;
}
```

See the [example](./example) directory for a more interesting example.

## Load Paths

By default, `mpp` will look for file paths relative to the working directory. In
order to specify the paths to search, you should use the `-I` command line flag:

```
$ mpp example/app.css
Can't find file other.css in /current/directory

$ mpp -Iexample:. example/app.css
.something {
  padding: 0;
}
...
```

The argument to `-I` is expected to be a list of directories separated by the
path separator (usually `:`).

Files will be searched relative to the directories in the load path in order. So
if your `-I` is `.:example`, mpp will first try to open the file
`./app.css`, and then `./example/app.css`. If neither is a file, then it will
exit with an error status.

## Make Dependencies

By passing `-M` (or `--make`) mpp will generate output suitable for a Makefile
to define the dependencies between files, according to the `#include` rules in
each processed file.

For example:

```
$ mpp -Iexample -M example/app.css
example/app.css: example/other.css

$
```

You can add this to your Makefile in order to let make handle this on its own:

``` Makefile
.deps.mk: $(ASSETS)
	@mpp -M $^ > $@

-include .deps.mk
```

Where `$(ASSETS)` is the list of all the assets that you're compiling. For
example, in one of my projects I have it set to

``` Makefile
ASSETS = $(shell find assets/ -type f)
```

This ensures that whenever a new asset is added / modified, `.deps.mk` is
rebuilt, and thus the dependencies are kept up-to-date.

## License

Licensed under the MIT license. See the attached [LICENSE](./LICENSE) file for
details.
