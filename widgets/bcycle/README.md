## B-cycle Widget

![Screenshot](http://f.cl.ly/items/3p15302Y123I2M3X1l3X/Screen%20Shot%202013-11-27%20at%2010.08.52%20AM.png)

B-cycle is a bike sharing service that operates in several American cities. More information at [their website](https://www.bcycle.com). This widget allows you to use the station ID in a widget to get the current count of bikes and docks available to show on your [Dashing](https://github.com/Shopify/dashing) dashboard.

## Demo

A demo repository is [available on GitHub](https://github.com/stephenyeargin/dashing-bcycle) and here is a [live Dashboard on Heroku](http://dashing-bcycle.herokuapp.com/).

## Obtaining an API Token

[Contact B-Cycle](https://www.bcycle.com/contactus.aspx) for an API Token. You will be asked to complete an agreement not to abuse / resell the data. After you returned that signed, they will give you an API Token along with a PDF version of the documentation.

## Installation

At the top of `jobs/bcycle.rb`, you will see the two required enviornment variables (or simply modify that file to suit your needs).

* `BCYCLE_API_KEY`
* `BCYCLE_PROGRAM_ID`

Use the endpoint in the documentation to get a list of active "programs" (usually corespond to a city).

Copy these files into their appropriate spot or use `dashing install 7678371` in the project directory to have Dashing do it for you.

After the job is up and running, you simply add the following syntax to your `{dashboard}.erb` file like any other widget.

```
  <li data-row="1" data-col="2" data-sizex="1" data-sizey="1">
   <div data-id="bcycle_2315" data-view="Bcycle"></div>
  </li>
```

Note that you will want to change the `bcycle_2315` to `bcycle_{your_station_id}`. You can have as many stations as you want on a dashboard.

The `bike.svg` needs to be moved into your `assets/images/` folder manually.