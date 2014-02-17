Chamber
=======

Chamber is a tool that notify the message translated by using [The Microsoft Translator API](http://www.microsoft.com/en-us/translator/developers.aspx) to [Slack](https://slack.com/).
Currently, chamber supports translating from English to Japanese and the opposite it.
The name of Chamber is taken from the character by the Japanese animation "[Gargantia on the Verdurous Planet](http://gargantia.jp/)"(翠星のガルガンティア).


## Requirements

- Use Slack
  - Create "Outgoing Webhooks"
    - Set on the "Channel"
    - Not set on "Trigger Word(s)", *it's important*
    - Set a server url (like "https://chamber.example.com") on the "URL(s)". If you have a valid certification for ssl, you should use it. *But self signed certification does not work*
  - Create "Incoming Webhooks"
    - Set on the "Channel"
      - It is recommened that you set the channel that is the same as "Outgoing Webhooks", because this tool seems true to bot.
    - After creating, you can confirm the token of the integration

- Have Windows Azure Marketplace account
  - If you don't have it, you can create the account in https://datamarket.azure.com/
  - Create an application with Microsoft Translate API
    - After creating, you can confirm the client secret of the application

## How to use

You must set environments below keys.

* SLACK_TEAM
* SLACK_ACCESS_TOKEN
* SLACK_CHANNEL
* SLACK_USERNAME
* AZURE_CLIENT_ID
* AZURE_CLIENT_SECRET

If you want to run on Heroku, you must set environments like below.

        $ heroku config:set SLACK_TEAM="your_slack_domain"
        $ heroku config:set SLACK_ACCESS_TOKEN="incoming_webhooks_token"
        $ heroku config:set SLACK_CHANNEL="#incoming_webhooks_channel"
        $ heroku config:set SLACK_USERNAME="incoming_webhooks_username"
        $ heroku config:set AZURE_CLIENT_ID="azure_client_id"
        $ heroku config:set AZURE_CLIENT_SECRET="azure_client_secret"


Start chamber.

        $ bundle install
        $ bundle exec thin start
