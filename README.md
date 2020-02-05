# Bitrise Sample Add-on

This sample add-on's purpose is to give the 3rd party developers a basic example for Bitrise Add-ons. Also it has a related [step implementation](https://www.bitrise.io/integrations/steps/ascii-generator) for understanding how the integration works with Bitrise workflows.

## What this add-on does?

It's quite simple, you put the related step to your workflow and the add-on sends a Bitrise-themed ASCII art to the VM, which prints that to the build log. For the sake of example it has to examples, the first one is a `free`, which limits the number of successful ASCII art requests in 5. Also there is an `unlimited` plan, which allows unlimited number of requests.

## Structure

The project uses [Sinatra](http://sinatrarb.com) for implementing this application logic and stores in memory the application data to keep it lightweight.

You can find the handler implementations in the `app.rb` file, while the `data_store.rb` implements the in-memory data store of the application. In the `/views` folder the `dashboard.html.erb` shows an example of integrating the Bitrise Beam on the dashboard of your add-on. The project is dockerized and you can use `docker-compose up` command for starting the add-on locally.
