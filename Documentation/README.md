Circuit iOS SDK Documentation
------------------------------
Welcome to the Circuit iOS SDK Documentation. This Documentation should be good starting point to start building a text or media mobile application for iOS.

Documentation provide the language examples in **Objective-C** and **Swift**.

We are using the [Slate](https://github.com/lord/slate) based documentation.



Getting Started with Documentation
------------------------------

### Prerequisites

You're going to need:

- **Linux or OS X** — Windows may work, but is unsupported.
- **Ruby, version 2.3.1 or newer**
- **Bundler** — If Ruby is already installed, but the `bundle` command doesn't work, just run `gem install bundler` in a terminal.

### Getting Set Up


Initialize and start Slate. You can either do this locally, or with Vagrant:

```shell
# either run this to run locally
bundle install
bundle exec middleman server

# OR run this to run with vagrant
vagrant up
```

You can now see the docs at http://localhost:4567. Whoa! That was fast!

Now that Slate is all set up on your machine, you'll probably want to learn more about [editing Slate markdown](https://github.com/lord/slate/wiki/Markdown-Syntax), or [how to publish your docs](https://github.com/lord/slate/wiki/Deploying-Slate).

If you'd prefer to use Docker, instructions are available [in the wiki](https://github.com/lord/slate/wiki/Docker).

### Note on JavaScript Runtime

For those who don't have JavaScript runtime or are experiencing JavaScript runtime issues with ExecJS, it is recommended to add the [rubyracer gem](https://github.com/cowboyd/therubyracer) to your gemfile and run `bundle` again.
