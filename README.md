# Jarvis

This is a version of GitHub's Campfire bot, [hubot](https://github.com/github/hubot). He's pretty cool.

This version is designed to be deployed on the Cerebro server. The live version is accessable by the #jarvis channel on the courseshark IRC.

## Playing with Jarvis

You'll need to install the necessary dependencies for hubot. All of
those dependencies are provided by [npm][npmjs].

[npmjs]: http://npmjs.org

## HTTP Listener

Hubot has a HTTP listener which listens on the port specified by the `PORT`
environment variable.

You can specify routes to listen on in your scripts by using the `router`
property on `robot`.

```coffeescript
module.exports = (robot) ->
  robot.router.get "/hubot/version", (req, res) ->
    res.end robot.version
```

There are functions for GET, POST, PUT and DELETE, which all take a route and
callback function that accepts a request and a response.


### Testing Jarvis Locally

You can test your hubot by running the following.

    % bin/jarvis

You'll see some start up output about where your scripts come from and a
prompt.

    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading adapter shell
    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading scripts from /home/tomb/Development/hubot/scripts
    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading scripts from /home/tomb/Development/hubot/src/scripts
    Hubot>

Then you can interact with hubot by typing `jarvis help`.

    jarvis> jarvis help

    jarvis> animate me <query> - The same thing as `image me`, except adds a few
    convert me <expression> to <units> - Convert expression to given units.
    help - Displays all of the help commands that Hubot knows about.
    ...

Take a look at the scripts in the `./scripts` folder for examples.
Delete any scripts you think are silly.  Add whatever functionality you
want Jarvis to have.

## Adapters

Adapters are the interface to the service you want your hubot to run on. This
can be something like Campfire or IRC. There are a number of third party
adapters that the community have contributed. Check the
[hubot wiki][hubot-wiki] for the available ones.

If you would like to run a non-Campfire or shell adapter you will need to add
the adapter package as a dependency to the `package.json` file in the
`dependencies` section.

Once you've added the dependency and run `npm install` to install it you can
then run hubot with the adapter.

    % bin/jarvis -a <adapter>

Where `<adapter>` is the name of your adapter without the `hubot-` prefix.

[hubot-wiki]: https://github.com/github/hubot/wiki

## hubot-scripts

There will inevitably be functionality that everyone will want. Instead
of adding it to hubot itself, you can submit pull requests to
[hubot-scripts][hubot-scripts].

To enable scripts from the hubot-scripts package, add the script name with
extension as a double quoted string to the hubot-scripts.json file in this
repo.

[hubot-scripts]: https://github.com/github/hubot-scripts

## IRC Adapter Variables

If you are using the IRC adapter you will need to set some environment
variables. Refer to the documentation for other adapters and the configuraiton
of those, links to the adapters can be found on the [hubot wiki][hubot-wiki].

The IRC adapter requires only the following environment variables.

* `HUBOT_IRC_SERVER`
* `HUBOT_IRC_ROOMS`

And the following are optional.

* `HUBOT_IRC_NICK`
* `HUBOT_IRC_PORT`
* `HUBOT_IRC_PASSWORD`
* `HUBOT_IRC_NICKSERV_PASSWORD`
* `HUBOT_IRC_NICKSERV_USERNAME`
* `HUBOT_IRC_SERVER_FAKE_SSL`
* `HUBOT_IRC_UNFLOOD`
* `HUBOT_IRC_DEBUG`
* `HUBOT_IRC_USESSL`

## Restart the bot

If you are on the Cerebro server, check out the repository then run `restart jarvis` and the jarvis bot will restart

