
# Instructions

clone the repository and then:

```bash
$ bundle
$ rails server start thin
```

And in another console (or browser):

```bash
$ curl http://localhost:3000/
```

The server will write "Thread suspended" and then sleep until another request is made
either with curl or a browser.

