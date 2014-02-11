This cookbook includes support for running tests via Test Kitchen (1.1). This has some requirements.

1. You must be using the Git repository, rather than the downloaded cookbook from the Chef Community Site.
2. You must have Vagrant 1.1 or higher installed.
3. You must have a "sane" Ruby 1.9.3 environment.

Once the above requirements are met, install the additional requirements:

Install the berkshelf plugin for vagrant, and berkshelf to your local Ruby environment.

    vagrant plugin install vagrant-berkshelf
    gem install berkshelf

Install Test Kitchen and its Vagrant driver.

    bundle install

Once the above are installed, you should be able to run Test Kitchen:

    kitchen list
    kitchen test
