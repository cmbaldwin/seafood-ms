# README

Funabiki Online, our seafood business management system (hence 'seafood-ms'), was designed as an accounting tool for our small Japanese family oyster business. You can read more about the company at http://funabiki.info and order oysters from our WooCommerce site at http://samuraioyster.com. The tool quickly grew to make various jobs easier for office and floor staff. As the software was developed for the Japanese workplace, but Japanese is not my first language, most of the code is a mixture of both languages. This is a learning project and many artifacts remain in the code that professional code (read: a team of qualified engineers) wouldn't have. For example, proper internationalization, better MVC implementation, better data structure, less costly N+1 calls on the database, etc etc. This is an edited branch of the private repository mainly availiable for posterity. Implementation of this would require quite a bit of enviornmental setup, but is possible. I mainly include it as a show of my coding progress and in case anyone is looking for InfoMart, Rakuten, or WooCommerce implementation hints/help on their own projects.

The platform currently includes (models capitalized):
-Product data input system, with an integrated overhead cost estimation tool based on associated Materials.
-A wholesale Market (volume moving client) daily accounting tool, including specific statistics about Products and their types.
-An integration tool (specific to our needs) for the Rakuten (楽天) E Commerce site's API which tracks daily order and shipping data, including a printable daily shipping list.
-An integration tool (specific to our needs) for the Infomart  (インフォマート) B2B restaurant supply system (unfortunatey including scraping by the Mechanize gem, as Infomart has no API), including a printable daily shipping list.
-A Noshi (熨斗) generator which is integrated with Google Cloud (A noshi is a wrapper with a name on it used for traditional Japanese gifts).
-A tool for creating (and scheduled daily) printable expiration cards of any type (in our case for raw shelled oysters).
-Simple infographics for yearly sales data and statistics.
-A system for tracking daily intake for shelled and shucked oysters, their farmers, and payment for those raw ingredients (and printable payment reciepts).
-A simple reciept (領収証) generator for online customers.
-Frozen product inventory tracking system.

Current and future projects include:
-Market based statistics. Product based statistics and analysis tools.
-Automate processing of orders through the Rakuten and Woocommerce API to further lessen manual computer processing/data-entry work.
-Further improvements and progress on the Frozen product tracking system.
-Lock record functionality for records over a certain age (currently the system may have issues with changing, say, material prices and then updating old Profit records).
-Product volume/ Raw Oysters usage calculation integration with the daily Profit accounting system (more thorough accounting tool, which is currently done manually on paper with daily and weekly averages).
-Exapandable oyster intake data (currently it only includes Sakoshi and Aioi oysters, but we'd like to ability to track and add oysters from any number of suppliers/farmers).
-Efficency improvments through the code, including better usage of caching (though Redis has helped a lot with this).
-Profit and volume calculation/integration automation for data already in the system for Rakuten and Infomart.
-Styrofoam box supply/inventtory tracker (will help with ordering boxes and estimates of used--this is currently all done manually on paper).
-Automated Rakuten/Infomart order processing using their API and/or Mechanize (currently this is done manually by part-time employees).

* Ruby version
	'2.6.5'

* Rails version
	'5.2.1'

* System dependencies
	Deployed on Heroku's Ubunbtu/Ruby server

* Configuration, Setup and Deployment
	Heroku-18 stack.
	https://devcenter.heroku.com/articles/getting-started-with-ruby
	Heroku's AWS IP range: https://ip-ranges.amazonaws.com/ip-ranges.json

	-> Buildpack Setup (in order)
	 ・ heroku/ruby
	 ・ https://github.com/weibeld/heroku-buildpack-graphviz
	 ・ heroku/metrics

	This project currently uses these Heroku add-ons:
	Heroku Postgres (database)
	Heroku Scheduler (for automated tasks)
	SendGrid (for user emails)
	Heroku Redis (caching, app speed)

* Gems that require setup/enviornment variables (passwords and api keys, etc).
	'devise'
	'carrierwave'
	'carrierwave-google-storage'
	'sendgrid-ruby'
	'woocommerce_api' (For our woocommerce integration)
	'httparty' (this app needs a Rakuten API key)
